import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import 'database_provider.dart';

/// Repositório de contas exposto para a camada de apresentação.
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Lista reativa de todas as contas.
final accountsProvider = StreamProvider<List<AccountEntity>>((ref) {
  return ref.watch(accountRepositoryProvider).watchAll();
});
