import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/data/database/app_database.dart';
import 'package:fintrack/data/repositories/fixed_expense_repository_impl.dart';
import 'package:fintrack/data/repositories/transaction_repository_impl.dart';

/// Mês corrente no formato 'yyyy-MM'.
String _currentMonth() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}';
}

void main() {
  late AppDatabase db;
  late FixedExpenseRepositoryImpl repository;
  late TransactionRepositoryImpl transactions;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = FixedExpenseRepositoryImpl(db);
    transactions = TransactionRepositoryImpl(db);
  });

  tearDown(() async => db.close());

  test('Pagar um fixo cria a transação e marca o mês como pago', () async {
    final id = await repository.create(
      type: 'despesa',
      amount: 50000,
      day: 10,
      description: 'Aluguel',
    );

    await repository.pay(id, month: _currentMonth());

    final rows = await transactions.watchAll().first;
    expect(rows, hasLength(1));
    expect(rows.single.amount, 50000);
    expect(rows.single.description, 'Aluguel');
    expect(rows.single.date.day, 10);

    final payments = await repository.watchPayments().first;
    expect(payments, hasLength(1));
    expect(payments.single.month, _currentMonth());
    expect(payments.single.transactionId, rows.single.id);
  });

  test('Pagar duas vezes o mesmo mês não duplica a transação', () async {
    final id = await repository.create(
      type: 'despesa',
      amount: 9900,
      day: 5,
      description: 'Streaming',
    );

    await repository.pay(id, month: _currentMonth());
    await repository.pay(id, month: _currentMonth());

    final rows = await transactions.watchAll().first;
    expect(rows, hasLength(1));
  });

  test('Desfazer o pagamento remove a transação do extrato', () async {
    final id = await repository.create(
      type: 'despesa',
      amount: 12000,
      day: 15,
      description: 'Internet',
    );
    await repository.pay(id, month: _currentMonth());
    final payment = (await repository.watchPayments().first).single;

    await repository.unpay(payment.id);

    expect(await transactions.watchAll().first, isEmpty);
    expect(await repository.watchPayments().first, isEmpty);
  });

  test('Excluir o fixo mantém as transações já pagas no extrato', () async {
    final id = await repository.create(
      type: 'despesa',
      amount: 80000,
      day: 8,
      description: 'Energia',
    );
    await repository.pay(id, month: _currentMonth());

    await repository.delete(id);

    expect(await repository.watchAll().first, isEmpty);
    expect(await repository.watchPayments().first, isEmpty);
    expect(await transactions.watchAll().first, hasLength(1));
  });

  test('Dia de vencimento é limitado ao fim do mês', () async {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final id = await repository.create(
      type: 'despesa',
      amount: 7000,
      day: 31,
      description: 'Academia',
    );

    await repository.pay(id, month: _currentMonth());

    final row = (await transactions.watchAll().first).single;
    expect(row.date.day, 31.clamp(1, daysInMonth));
  });
}
