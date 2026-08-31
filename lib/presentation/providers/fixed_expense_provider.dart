import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/fixed_expense_repository_impl.dart';
import '../../domain/entities/fixed_expense_entity.dart';
import '../../domain/repositories/fixed_expense_repository.dart';
import 'database_provider.dart';

/// Repositório de lançamentos fixos exposto para a camada de apresentação.
final fixedExpenseRepositoryProvider =
    Provider<FixedExpenseRepository>((ref) {
  return FixedExpenseRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Lista reativa de todos os lançamentos fixos cadastrados.
final fixedExpensesProvider = StreamProvider<List<FixedExpenseEntity>>((ref) {
  return ref.watch(fixedExpenseRepositoryProvider).watchAll();
});

/// Lista reativa de todos os pagamentos confirmados de lançamentos fixos.
final fixedPaymentsProvider =
    StreamProvider<List<FixedExpensePaymentEntity>>((ref) {
  return ref.watch(fixedExpenseRepositoryProvider).watchPayments();
});
