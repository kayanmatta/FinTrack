import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/utils/finance_metrics.dart';
import 'package:fintrack/domain/entities/transaction_entity.dart';

TransactionEntity _tx({
  required int id,
  required String type,
  required int amount,
  required DateTime date,
  int? categoryId,
}) => TransactionEntity(
  id: id,
  type: type,
  amount: amount,
  categoryId: categoryId,
  accountId: null,
  date: date,
  description: null,
  createdAt: date,
);

void main() {
  // Referência fixa: junho/2026 — mantém os testes determinísticos.
  final reference = DateTime(2026, 6, 20);
  final transactions = [
    _tx(id: 1, type: 'receita', amount: 300000, date: DateTime(2026, 6, 5)),
    _tx(
      id: 2,
      type: 'despesa',
      amount: 120000,
      date: DateTime(2026, 6, 10),
      categoryId: 1,
    ),
    _tx(
      id: 3,
      type: 'despesa',
      amount: 30000,
      date: DateTime(2026, 6, 12),
      categoryId: 2,
    ),
    _tx(id: 4, type: 'receita', amount: 250000, date: DateTime(2026, 5, 5)),
    _tx(
      id: 5,
      type: 'despesa',
      amount: 100000,
      date: DateTime(2026, 5, 8),
      categoryId: 1,
    ),
    _tx(
      id: 6,
      type: 'despesa',
      amount: 80000,
      date: DateTime(2026, 4, 15),
      categoryId: 1,
    ),
  ];

  test('Calcula totais do mês e saldo acumulado', () {
    expect(incomeOfMonth(transactions, reference), 300000);
    expect(expensesOfMonth(transactions, reference), 150000);
    expect(savingsOfMonth(transactions, reference), 150000);
    expect(totalBalance(transactions), 220000);
  });

  test('dashboardMetrics retorna valores e variação vs mês anterior', () {
    final metrics = dashboardMetrics(transactions, reference: reference);

    expect(metrics.balance, 220000);
    // Saldo anterior = 220000 - 150000 (resultado do mês) = 70000.
    expect(metrics.balanceChange, closeTo(214.286, 0.01));
    expect(metrics.income, 300000);
    expect(metrics.incomeChange, closeTo(20.0, 0.001));
    expect(metrics.expenses, 150000);
    expect(metrics.expensesChange, closeTo(50.0, 0.001));
    expect(metrics.savings, 150000);
    expect(metrics.savingsChange, closeTo(0.0, 0.001));
  });

  test('Variação percentual é null quando o mês anterior é zero', () {
    expect(percentChange(10000, 0), isNull);
    expect(percentChange(20000, 10000), closeTo(100.0, 0.001));
    expect(
      dashboardMetrics(
        [_tx(id: 1, type: 'receita', amount: 100, date: DateTime(2026, 6, 1))],
        reference: reference,
      ).incomeChange,
      isNull,
    );
  });

  test('spendingByCategory agrupa despesas do mês com percentuais', () {
    final spending = spendingByCategory(transactions, reference: reference);

    expect(spending, hasLength(2));
    expect(spending[0].categoryId, 1);
    expect(spending[0].amount, 120000);
    expect(spending[0].percentage, closeTo(80.0, 0.001));
    expect(spending[1].categoryId, 2);
    expect(spending[1].amount, 30000);
    expect(spending[1].percentage, closeTo(20.0, 0.001));

    // Sem despesas no mês → lista vazia.
    expect(
      spendingByCategory(transactions, reference: DateTime(2026, 1)),
      isEmpty,
    );
  });

  test('expenseEvolution cobre os últimos 6 meses em ordem cronológica', () {
    final evolution = expenseEvolution(transactions, reference: reference);

    expect(evolution, hasLength(6));
    expect(evolution.first.month, DateTime(2026, 1));
    expect(evolution.last.month, DateTime(2026, 6));
    expect(evolution.map((m) => m.amount).toList(), [
      0,
      0,
      0,
      80000,
      100000,
      150000,
    ]);
  });

  test('latestTransactions retorna as mais recentes primeiro', () {
    final latest = latestTransactions(transactions, count: 3);

    expect(latest.map((t) => t.id).toList(), [3, 2, 1]);
    expect(latestTransactions(transactions).map((t) => t.id).toList(), [
      3,
      2,
      1,
      5,
      4,
    ]);
  });
}
