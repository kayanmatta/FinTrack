import 'package:drift/drift.dart';

import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../database/app_database.dart';

/// Implementação Drift do repositório de metas (camada de dados).
class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._db);

  final AppDatabase _db;

  GoalEntity _toEntity(Goal row) => GoalEntity(
        id: row.id,
        name: row.name,
        targetAmount: row.targetAmount,
        deadline: row.deadline,
        icon: row.icon,
        color: row.color,
        createdAt: row.createdAt,
      );

  GoalContributionEntity _toContribution(GoalContribution row) =>
      GoalContributionEntity(
        id: row.id,
        goalId: row.goalId,
        amount: row.amount,
        date: row.date,
      );

  @override
  Stream<List<GoalEntity>> watchAll() {
    return (_db.select(_db.goals)
          ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
            (table) => OrderingTerm.desc(table.id),
          ]))
        .watch()
        .map((rows) => [for (final row in rows) _toEntity(row)]);
  }

  @override
  Stream<List<GoalContributionEntity>> watchContributions(int goalId) {
    return (_db.select(_db.goalContributions)
          ..where((table) => table.goalId.equals(goalId))
          ..orderBy([
            (table) => OrderingTerm.desc(table.date),
            (table) => OrderingTerm.desc(table.id),
          ]))
        .watch()
        .map((rows) => [for (final row in rows) _toContribution(row)]);
  }

  @override
  Future<int> create({
    required String name,
    required int targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
  }) {
    return _db.into(_db.goals).insert(
          GoalsCompanion.insert(
            name: name,
            targetAmount: Value(targetAmount),
            deadline: Value(deadline),
            icon: Value(icon),
            color: Value(color),
          ),
        );
  }

  @override
  Future<void> delete(int id) {
    return _db.transaction(() async {
      await (_db.delete(_db.goalContributions)
            ..where((table) => table.goalId.equals(id)))
          .go();
      await (_db.delete(_db.goals)..where((table) => table.id.equals(id)))
          .go();
    });
  }

  @override
  Future<int> addContribution({
    required int goalId,
    required int amount,
    required DateTime date,
  }) {
    return _db.into(_db.goalContributions).insert(
          GoalContributionsCompanion.insert(
            goalId: goalId,
            amount: Value(amount),
            date: date,
          ),
        );
  }
}
