import '../../domain/entities/goal_entity.dart';

/// Fórmulas determinísticas das metas financeiras (Sprint 7).
///
/// Funções puras: recebem metas, aportes e a data de referência,
/// sem banco, UI ou relógio global. Valores em centavos.

/// Total aportado na meta (S7-03).
int totalContributed(List<GoalContributionEntity> contributions) {
  var total = 0;
  for (final contribution in contributions) {
    total += contribution.amount;
  }
  return total;
}

/// Percentual concluído da meta (pode passar de 100).
double progressPercent({required int targetAmount, required int contributed}) {
  if (targetAmount <= 0) return 0;
  return contributed / targetAmount * 100;
}

/// Meta concluída quando o aportado alcança o alvo (S7-05).
bool isGoalCompleted({required int targetAmount, required int contributed}) =>
    targetAmount > 0 && contributed >= targetAmount;

/// Quanto falta para concluir (nunca negativo).
int remainingAmount({required int targetAmount, required int contributed}) {
  final remaining = targetAmount - contributed;
  return remaining < 0 ? 0 : remaining;
}

/// Previsão de conclusão pela média mensal de aportes (S7-04).
///
/// Média = total aportado / meses desde o primeiro aporte (mínimo 1).
/// Retorna `null` quando não há aportes ou a meta já foi concluída.
DateTime? projectedCompletion({
  required int targetAmount,
  required List<GoalContributionEntity> contributions,
  required DateTime now,
}) {
  final total = totalContributed(contributions);
  if (contributions.isEmpty || total <= 0 || targetAmount <= 0) return null;
  if (total >= targetAmount) return null;

  var first = contributions.first.date;
  for (final contribution in contributions) {
    if (contribution.date.isBefore(first)) first = contribution.date;
  }
  final monthsElapsed =
      ((now.year - first.year) * 12 + now.month - first.month + 1).clamp(1, 1 << 31);
  final monthlyAverage = total / monthsElapsed;
  final remaining = targetAmount - total;
  final monthsNeeded = (remaining / monthlyAverage).ceil();
  return DateTime(now.year, now.month + monthsNeeded, now.day);
}
