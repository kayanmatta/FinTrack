import '../database/app_database.dart';
import '../../domain/repositories/database_repository.dart';

/// Implementação do contrato de banco usando Drift (camada de dados).
class DatabaseRepositoryImpl implements DatabaseRepository {
  DatabaseRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> ensureReady() => _db.ensureReady();
}
