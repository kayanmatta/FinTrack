import 'package:drift/drift.dart';

import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../database/app_database.dart';

/// Implementação Drift do repositório de contas (camada de dados).
class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._db);

  final AppDatabase _db;

  AccountEntity _toEntity(Account row) {
    return AccountEntity(
      id: row.id,
      name: row.name,
      type: row.type,
      initialBalance: row.initialBalance,
      color: row.color ?? '#6C2BD9',
      createdAt: row.createdAt,
    );
  }

  @override
  Stream<List<AccountEntity>> watchAll() {
    return _db
        .select(_db.accounts)
        .watch()
        .map((rows) => [for (final row in rows) _toEntity(row)]);
  }

  @override
  Future<int> create({
    required String name,
    required String type,
    required int initialBalance,
    required String color,
  }) {
    return _db.into(_db.accounts).insert(
          AccountsCompanion.insert(
            name: name,
            type: Value(type),
            initialBalance: Value(initialBalance),
            color: Value(color),
          ),
        );
  }

  @override
  Future<void> update(AccountEntity account) {
    return (_db.update(_db.accounts)
          ..where((table) => table.id.equals(account.id)))
        .write(
      AccountsCompanion(
        name: Value(account.name),
        type: Value(account.type),
        initialBalance: Value(account.initialBalance),
        color: Value(account.color),
      ),
    );
  }

  @override
  Future<void> delete(int id) {
    return _db.transaction(() async {
      // Transações vinculadas ficam sem conta em vez de quebrar o FK.
      await (_db.update(_db.transactions)
            ..where((table) => table.accountId.equals(id)))
          .write(const TransactionsCompanion(accountId: Value(null)));
      await (_db.delete(_db.accounts)..where((table) => table.id.equals(id)))
          .go();
    });
  }
}
