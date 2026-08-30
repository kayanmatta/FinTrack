import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import 'database_provider.dart';

/// Repositório de metas exposto para a camada de apresentação.
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Todas as metas do usuário (S7-03).
final goalsProvider = StreamProvider<List<GoalEntity>>((ref) {
  return ref.watch(goalRepositoryProvider).watchAll();
});

/// Aportes da meta [goalId] (S7-04).
final goalContributionsProvider =
    StreamProvider.family<List<GoalContributionEntity>, int>((ref, goalId) {
  return ref.watch(goalRepositoryProvider).watchContributions(goalId);
});
