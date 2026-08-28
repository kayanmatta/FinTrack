import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/database_repository_impl.dart';
import '../../domain/repositories/database_repository.dart';

/// Instância única do banco de dados local.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Repositório de banco exposto para as camadas superiores.
final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return DatabaseRepositoryImpl(ref.watch(appDatabaseProvider));
});
