/// Meta de economia do usuário (Sprint 7).
class GoalEntity {
  const GoalEntity({
    this.id,
    required this.name,
    required this.targetAmount,
    this.deadline,
    this.icon,
    this.color,
    required this.createdAt,
  });

  final int? id;
  final String name;

  /// Valor alvo em centavos.
  final int targetAmount;
  final DateTime? deadline;
  final String? icon;
  final String? color;
  final DateTime createdAt;
}

/// Aporte realizado em uma meta (S7-02).
class GoalContributionEntity {
  const GoalContributionEntity({
    this.id,
    required this.goalId,
    required this.amount,
    required this.date,
  });

  final int? id;
  final int goalId;

  /// Valor do aporte em centavos.
  final int amount;
  final DateTime date;
}
