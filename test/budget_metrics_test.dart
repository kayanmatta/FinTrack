import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/utils/budget_metrics.dart';
import 'package:fintrack/domain/entities/budget_entity.dart';
import 'package:fintrack/domain/entities/transaction_entity.dart';

/// Transação de despesa auxiliar para os cenários de teste.
TransactionEntity _expense({
  required int id,
  required int categoryId,
  required int amount,
  required DateTime date,
}) =>
    TransactionEntity(
      id: id,
      type: 'despesa',
      amount: amount,
      categoryId: categoryId,
      accountId: null,
      date: date,
      description: null,
      createdAt: date,
    );

void main() {
  group('monthKey', () {
    test('Formata no padrão yyyy-MM com zeros à esquerda', () {
      expect(monthKey(DateTime(2026, 8, 15)), '2026-08');
      expect(monthKey(DateTime(2026, 1, 31)), '2026-01');
      expect(monthKey(DateTime(2026, 12, 1)), '2026-12');
    });
  });

  group('BudgetStatus', () {
    test('Percentual, restante e nível abaixo de 80%', () {
      const status = BudgetStatus(
        categoryId: 1,
        allocated: 100000,
        spent: 79000,
      );
      expect(status.percent, closeTo(79.0, 0.01));
      expect(status.remaining, 21000);
      expect(status.level, BudgetLevel.ok);
    });

    test('Nível de alerta a partir de 80% (S6-03)', () {
      const status = BudgetStatus(
        categoryId: 1,
        allocated: 100000,
        spent: 80000,
      );
      expect(status.percent, 80.0);
      expect(status.level, BudgetLevel.warning);
    });

    test('Nível estourado a partir de 100% com restante negativo', () {
      const status = BudgetStatus(
        categoryId: 1,
        allocated: 100000,
        spent: 120000,
      );
      expect(status.percent, 120.0);
      expect(status.remaining, -20000);
      expect(status.level, BudgetLevel.exceeded);
    });

    test('Sem limite definido o percentual é zero e nível ok', () {
      const status = BudgetStatus(
        categoryId: 1,
        allocated: 0,
        spent: 5000,
      );
      expect(status.percent, 0);
      expect(status.level, BudgetLevel.ok);
    });
  });

  group('buildBudgetStatuses', () {
    final month = DateTime(2026, 8);
    final budgets = [
      const BudgetEntity(
        categoryId: 1,
        month: '2026-08',
        limitAmount: 100000,
      ),
      const BudgetEntity(
        categoryId: 2,
        month: '2026-08',
        limitAmount: 50000,
      ),
    ];

    test('Soma despesas do mês por categoria e ordena por percentual', () {
      final transactions = [
        _expense(
          id: 1,
          categoryId: 1,
          amount: 60000,
          date: DateTime(2026, 8, 5),
        ),
        _expense(
          id: 2,
          categoryId: 1,
          amount: 30000,
          date: DateTime(2026, 8, 20),
        ),
        _expense(
          id: 3,
          categoryId: 2,
          amount: 10000,
          date: DateTime(2026, 8, 10),
        ),
      ];

      final statuses = buildBudgetStatuses(budgets, transactions, month);
      expect(statuses, hasLength(2));
      // Categoria 1 gastou 90% (vem primeiro) e categoria 2 gastou 20%.
      expect(statuses[0].categoryId, 1);
      expect(statuses[0].spent, 90000);
      expect(statuses[0].percent, 90.0);
      expect(statuses[1].categoryId, 2);
      expect(statuses[1].spent, 10000);
    });

    test('Ignora receitas, outros meses e categoria nula', () {
      final transactions = [
        TransactionEntity(
          id: 1,
          type: 'receita',
          amount: 400000,
          categoryId: null,
          accountId: null,
          date: DateTime(2026, 8, 5),
          description: null,
          createdAt: DateTime(2026, 8, 5),
        ),
        _expense(
          id: 2,
          categoryId: 1,
          amount: 70000,
          date: DateTime(2026, 7, 25),
        ),
        TransactionEntity(
          id: 3,
          type: 'despesa',
          amount: 8000,
          categoryId: null,
          accountId: null,
          date: DateTime(2026, 8, 12),
          description: null,
          createdAt: DateTime(2026, 8, 12),
        ),
      ];

      final statuses = buildBudgetStatuses(budgets, transactions, month);
      expect(statuses.every((status) => status.spent == 0), isTrue);
    });
  });

  group('budgetTotals e budgetAlerts', () {
    test('Totais somam alocado e gasto; disponível é a diferença', () {
      const statuses = [
        BudgetStatus(categoryId: 1, allocated: 100000, spent: 90000),
        BudgetStatus(categoryId: 2, allocated: 50000, spent: 60000),
      ];
      final totals = budgetTotals(statuses);
      expect(totals.allocated, 150000);
      expect(totals.spent, 150000);
      expect(totals.available, 0);
    });

    test('Alertas retornam apenas categorias em warning ou exceeded', () {
      const statuses = [
        BudgetStatus(categoryId: 1, allocated: 100000, spent: 90000),
        BudgetStatus(categoryId: 2, allocated: 50000, spent: 60000),
        BudgetStatus(categoryId: 3, allocated: 80000, spent: 10000),
      ];
      final alerts = budgetAlerts(statuses);
      expect(alerts.map((status) => status.categoryId), [1, 2]);
    });
  });
}
