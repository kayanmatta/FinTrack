import 'dart:async';

import '../../core/utils/alert_builder.dart';
import '../../core/utils/budget_metrics.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../database/app_database.dart';

/// Implementação Drift da central de notificações (camada de dados).
///
/// Os alertas são recalculados a cada mudança em qualquer tabela de
/// origem; somente as chaves de alertas lidos são persistidas.
class AlertRepositoryImpl implements AlertRepository {
  AlertRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<AlertEntity>> watchPending() {
    late StreamController<void> controller;
    final subscriptions = <StreamSubscription<void>>[];
    controller = StreamController<void>(
      onListen: () {
        void trigger(Object? _) => controller.add(null);
        subscriptions
          ..add(_db.select(_db.transactions).watch().listen(trigger))
          ..add(_db.select(_db.budgets).watch().listen(trigger))
          ..add(_db.select(_db.goals).watch().listen(trigger))
          ..add(_db.select(_db.goalContributions).watch().listen(trigger))
          ..add(_db.select(_db.categories).watch().listen(trigger))
          ..add(_db.select(_db.readAlerts).watch().listen(trigger));
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream.asyncMap((_) => _computePending());
  }

  @override
  Future<void> markRead(List<String> keys) async {
    if (keys.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.readAlerts, [
        for (final key in keys) ReadAlertsCompanion.insert(alertKey: key),
      ]);
    });
  }

  Future<List<AlertEntity>> _computePending() async {
    final now = DateTime.now();
    final month = monthKey(now);

    final txRows = await _db.select(_db.transactions).get();
    final budgetRows = await (_db.select(_db.budgets)
          ..where((table) => table.month.equals(month)))
        .get();
    final goalRows = await _db.select(_db.goals).get();
    final contributionRows = await _db.select(_db.goalContributions).get();
    final categoryRows = await _db.select(_db.categories).get();
    final readRows = await _db.select(_db.readAlerts).get();

    final contributedByGoal = <int, int>{};
    for (final contribution in contributionRows) {
      contributedByGoal[contribution.goalId] =
          (contributedByGoal[contribution.goalId] ?? 0) + contribution.amount;
    }

    final readKeys = {for (final row in readRows) row.alertKey};
    final alerts = buildAlerts(
      transactions: [for (final row in txRows) _toTransaction(row)],
      budgets: [for (final row in budgetRows) _toBudget(row)],
      goals: [for (final row in goalRows) _toGoal(row)],
      contributedByGoal: contributedByGoal,
      categoryNames: {
        for (final row in categoryRows) row.id: row.name,
      },
      now: now,
    );
    return [for (final alert in alerts) if (!readKeys.contains(alert.key)) alert];
  }

  TransactionEntity _toTransaction(Transaction row) => TransactionEntity(
        id: row.id,
        type: row.type,
        amount: row.amount,
        categoryId: row.categoryId,
        accountId: row.accountId,
        date: row.date,
        description: row.description,
        createdAt: row.createdAt,
      );

  BudgetEntity _toBudget(Budget row) => BudgetEntity(
        id: row.id,
        categoryId: row.categoryId,
        month: row.month,
        limitAmount: row.limitAmount,
      );

  GoalEntity _toGoal(Goal row) => GoalEntity(
        id: row.id,
        name: row.name,
        targetAmount: row.targetAmount,
        deadline: row.deadline,
        icon: row.icon,
        color: row.color,
        createdAt: row.createdAt,
      );
}
