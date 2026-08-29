import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/transaction_entity.dart';

/// Fórmulas determinísticas do orçamento mensal (Sprint 6).
///
/// Funções puras: recebem orçamentos, transações e o mês de referência,
/// sem banco, UI ou relógio global. Valores em centavos.

/// Chave 'yyyy-MM' de um mês (formato salvo no banco).
String monthKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

/// Nível de alerta de um orçamento de categoria (S6-03).
enum BudgetLevel {
  /// Abaixo de 80% do limite.
  ok,

  /// Entre 80% e 99,9% do limite.
  warning,

  /// 100% ou mais do limite.
  exceeded,
}

/// Situação de uma categoria no mês: alocado vs. gasto (S6-02/S6-04).
class BudgetStatus {
  const BudgetStatus({
    required this.categoryId,
    required this.allocated,
    required this.spent,
  });

  final int categoryId;
  final int allocated;
  final int spent;

  /// Percentual gasto do alocado (0 quando não há limite definido).
  double get percent => allocated == 0 ? 0 : spent / allocated * 100;

  /// Quanto ainda pode gastar no mês (negativo se estourou).
  int get remaining => allocated - spent;

  BudgetLevel get level =>
      percent >= 100
          ? BudgetLevel.exceeded
          : percent >= 80
              ? BudgetLevel.warning
              : BudgetLevel.ok;
}

/// Totais gerais do orçamento (S6-05).
class BudgetTotals {
  const BudgetTotals({
    required this.allocated,
    required this.spent,
  });

  final int allocated;
  final int spent;

  /// Quanto ainda pode gastar no mês (negativo se estourou).
  int get available => allocated - spent;
}

/// Calcula a situação de cada orçamento do mês de [month].
///
/// Ordena do maior percentual gasto para o menor, para destacar
/// primeiro as categorias em alerta.
List<BudgetStatus> buildBudgetStatuses(
  List<BudgetEntity> budgets,
  List<TransactionEntity> transactions,
  DateTime month,
) {
  final spentByCategory = <int, int>{};
  for (final transaction in transactions) {
    if (transaction.type != 'despesa' ||
        transaction.categoryId == null ||
        transaction.date.year != month.year ||
        transaction.date.month != month.month) {
      continue;
    }
    spentByCategory[transaction.categoryId!] =
        (spentByCategory[transaction.categoryId!] ?? 0) + transaction.amount;
  }
  final statuses = [
    for (final budget in budgets)
      BudgetStatus(
        categoryId: budget.categoryId,
        allocated: budget.limitAmount,
        spent: spentByCategory[budget.categoryId] ?? 0,
      ),
  ];
  statuses.sort((a, b) => b.percent.compareTo(a.percent));
  return statuses;
}

/// Totais alocado/gasto do mês (S6-05).
BudgetTotals budgetTotals(List<BudgetStatus> statuses) {
  var allocated = 0;
  var spent = 0;
  for (final status in statuses) {
    allocated += status.allocated;
    spent += status.spent;
  }
  return BudgetTotals(allocated: allocated, spent: spent);
}

/// Categorias em alerta (80% ou mais do limite) no mês (S6-03).
List<BudgetStatus> budgetAlerts(List<BudgetStatus> statuses) => [
  for (final status in statuses)
    if (status.level != BudgetLevel.ok) status,
];
