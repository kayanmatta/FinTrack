import '../entities/budget_entity.dart';

/// Contrato de persistência do orçamento mensal (Sprint 6).
abstract class BudgetRepository {
  /// Limites alocados no mês [month] ('yyyy-MM').
  Stream<List<BudgetEntity>> watchMonth(String month);

  /// Renda informada para o mês [month], ou `null` se ainda não definida.
  Stream<int?> watchIncome(String month);

  /// Substitui o orçamento do mês: renda + alocações por categoria.
  Future<void> save({
    required String month,
    required int income,
    required Map<int, int> allocations,
  });

  /// Copia as alocações de [fromMonth] para [toMonth] (ajuste rápido).
  Future<void> copyMonth(String fromMonth, String toMonth);
}
