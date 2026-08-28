import 'package:drift/drift.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../database/app_database.dart';

/// Implementação Drift do repositório de transações (camada de dados).
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._db);

  final AppDatabase _db;

  TransactionEntity _toEntity(Transaction row) {
    return TransactionEntity(
      id: row.id,
      type: row.type,
      amount: row.amount,
      categoryId: row.categoryId,
      accountId: row.accountId,
      date: row.date,
      description: row.description,
      createdAt: row.createdAt,
    );
  }

  @override
  Stream<List<TransactionEntity>> watchAll() {
    return (_db.select(_db.transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch()
        .map((rows) => [for (final row in rows) _toEntity(row)]);
  }

  @override
  Future<int> create({
    required String type,
    required int amount,
    int? categoryId,
    int? accountId,
    required DateTime date,
    String? description,
  }) {
    return _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            type: type,
            amount: Value(amount),
            categoryId: Value(categoryId),
            accountId: Value(accountId),
            date: date,
            description: Value(description),
          ),
        );
  }
}
