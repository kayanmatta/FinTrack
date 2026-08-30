/// Limite de orçamento alocado para uma categoria em um mês (Sprint 6).
class BudgetEntity {
  const BudgetEntity({
    this.id,
    required this.categoryId,
    required this.month,
    required this.limitAmount,
  });

  final int? id;
  final int categoryId;

  /// Mês de referência no formato 'yyyy-MM'.
  final String month;

  /// Limite alocado em centavos.
  final int limitAmount;
}
