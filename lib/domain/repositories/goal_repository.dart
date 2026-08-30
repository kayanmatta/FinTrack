import '../entities/goal_entity.dart';

/// Contrato de persistência das metas financeiras (Sprint 7).
abstract class GoalRepository {
  /// Todas as metas, da mais recente para a mais antiga.
  Stream<List<GoalEntity>> watchAll();

  /// Aportes da meta [goalId], do mais recente para o mais antigo.
  Stream<List<GoalContributionEntity>> watchContributions(int goalId);

  /// Cria uma meta e retorna o id gerado (S7-01).
  Future<int> create({
    required String name,
    required int targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
  });

  /// Exclui a meta e todos os seus aportes (S7-06).
  Future<void> delete(int id);

  /// Registra um aporte na meta e retorna o id gerado (S7-02).
  Future<int> addContribution({
    required int goalId,
    required int amount,
    required DateTime date,
  });
}
