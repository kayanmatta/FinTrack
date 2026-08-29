import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/budget_metrics.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import 'database_provider.dart';

/// Repositório de orçamento exposto para a camada de apresentação.
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Chave 'yyyy-MM' do mês atual.
final currentMonthKeyProvider = Provider<String>((ref) {
  return monthKey(DateTime.now());
});

/// Limites alocados no mês [month].
final budgetsProvider =
    StreamProvider.family<List<BudgetEntity>, String>((ref, month) {
  return ref.watch(budgetRepositoryProvider).watchMonth(month);
});

/// Renda informada no mês [month].
final budgetIncomeProvider = StreamProvider.family<int?, String>((
  ref,
  month,
) {
  return ref.watch(budgetRepositoryProvider).watchIncome(month);
});
