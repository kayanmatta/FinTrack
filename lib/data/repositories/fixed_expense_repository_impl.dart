import 'package:drift/drift.dart';

import '../../domain/entities/fixed_expense_entity.dart';
import '../../domain/repositories/fixed_expense_repository.dart';
import '../database/app_database.dart';

/// Implementação Drift do repositório de lançamentos fixos (camada de dados).
class FixedExpenseRepositoryImpl implements FixedExpenseRepository {
  FixedExpenseRepositoryImpl(this._db);

  final AppDatabase _db;

  FixedExpenseEntity _toEntity(FixedExpense row) {
    return FixedExpenseEntity(
      id: row.id,
      type: row.type,
      amount: row.amount,
      categoryId: row.categoryId,
      accountId: row.accountId,
      description: row.description,
      day: row.day,
      createdAt: row.createdAt,
    );
  }

  FixedExpensePaymentEntity _toPaymentEntity(FixedExpensePayment row) {
    return FixedExpensePaymentEntity(
      id: row.id,
      fixedId: row.fixedId,
      month: row.month,
      transactionId: row.transactionId,
      paidAt: row.paidAt,
    );
  }

  @override
  Stream<List<FixedExpenseEntity>> watchAll() {
    return _db
        .select(_db.fixedExpenses)
        .watch()
        .map((rows) => [for (final row in rows) _toEntity(row)]);
  }

  @override
  Stream<List<FixedExpensePaymentEntity>> watchPayments() {
    return _db
        .select(_db.fixedExpensePayments)
        .watch()
        .map((rows) => [for (final row in rows) _toPaymentEntity(row)]);
  }

  @override
  Future<int> create({
    required String type,
    required int amount,
    required int day,
    int? categoryId,
    int? accountId,
    String? description,
  }) {
    return _db.into(_db.fixedExpenses).insert(
          FixedExpensesCompanion.insert(
            amount: Value(amount),
            day: Value(day),
            type: Value(type),
            categoryId: Value(categoryId),
            accountId: Value(accountId),
            description: Value(description),
          ),
        );
  }

  @override
  Future<void> update(FixedExpenseEntity expense) {
    return (_db.update(_db.fixedExpenses)
          ..where((table) => table.id.equals(expense.id)))
        .write(
      FixedExpensesCompanion(
        type: Value(expense.type),
        amount: Value(expense.amount),
        categoryId: Value(expense.categoryId),
        accountId: Value(expense.accountId),
        description: Value(expense.description),
        day: Value(expense.day),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    // As transações já pagas permanecem no extrato; só o modelo e o
    // histórico de pagamentos são removidos.
    await (_db.delete(_db.fixedExpensePayments)
          ..where((table) => table.fixedId.equals(id)))
        .go();
    await (_db.delete(_db.fixedExpenses)..where((table) => table.id.equals(id)))
        .go();
  }

  @override
  Future<void> pay(int fixedId, {required String month}) async {
    final template = await (_db.select(_db.fixedExpenses)
          ..where((table) => table.id.equals(fixedId)))
        .getSingleOrNull();
    if (template == null) return;

    final alreadyPaid = await (_db.select(_db.fixedExpensePayments)
          ..where((table) =>
              table.fixedId.equals(fixedId) & table.month.equals(month)))
        .getSingleOrNull();
    if (alreadyPaid != null) return;

    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final monthNumber = int.parse(parts[1]);
    final daysInMonth = DateTime(year, monthNumber + 1, 0).day;
    final date = DateTime(year, monthNumber, template.day.clamp(1, daysInMonth));

    await _db.transaction(() async {
      final transactionId = await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              type: template.type,
              amount: Value(template.amount),
              categoryId: Value(template.categoryId),
              accountId: Value(template.accountId),
              date: date,
              description: Value(template.description),
            ),
          );
      await _db.into(_db.fixedExpensePayments).insert(
            FixedExpensePaymentsCompanion.insert(
              fixedId: fixedId,
              month: month,
              transactionId: Value(transactionId),
            ),
          );
    });
  }

  @override
  Future<void> unpay(int paymentId) async {
    final payment = await (_db.select(_db.fixedExpensePayments)
          ..where((table) => table.id.equals(paymentId)))
        .getSingleOrNull();
    if (payment == null) return;

    await _db.transaction(() async {
      if (payment.transactionId != null) {
        await (_db.delete(_db.transactions)
              ..where((table) => table.id.equals(payment.transactionId!)))
            .go();
      }
      await (_db.delete(_db.fixedExpensePayments)
            ..where((table) => table.id.equals(paymentId)))
          .go();
    });
  }
}
