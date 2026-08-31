import 'package:drift/drift.dart';

import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../database/app_database.dart';

/// Implementação Drift do repositório de orçamento (camada de dados).
class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._db);

  final AppDatabase _db;

  BudgetEntity _toEntity(Budget row) => BudgetEntity(
        id: row.id,
        categoryId: row.categoryId,
        month: row.month,
        limitAmount: row.limitAmount,
      );

  @override
  Stream<List<BudgetEntity>> watchMonth(String month) {
    return (_db.select(_db.budgets)
          ..where((table) => table.month.equals(month)))
        .watch()
        .map((rows) => [for (final row in rows) _toEntity(row)]);
  }

  @override
  Stream<int?> watchIncome(String month) {
    return (_db.select(_db.budgetIncomes)
          ..where((table) => table.month.equals(month)))
        .watchSingleOrNull()
        .map((row) => row?.amount);
  }

  @override
  Future<void> save({
    required String month,
    required int income,
    required Map<int, int> allocations,
  }) {
    return _db.transaction(() async {
      await (_db.delete(_db.budgets)
            ..where((table) => table.month.equals(month)))
          .go();
      await (_db.delete(_db.budgetIncomes)
            ..where((table) => table.month.equals(month)))
          .go();
      await _db
          .into(_db.budgetIncomes)
          .insert(
            BudgetIncomesCompanion.insert(month: month, amount: Value(income)),
          );
      // O batch precisa ser aguardado: sem o await, os inserts dos
      // limites eram perdidos ao fechar a transação (bug real do S6).
      await _db.batch((batch) {
        batch.insertAll(
          _db.budgets,
          [
            for (final entry in allocations.entries)
              if (entry.value > 0)
                BudgetsCompanion.insert(
                  categoryId: entry.key,
                  month: month,
                  limitAmount: Value(entry.value),
                ),
          ],
        );
      });
    });
  }

  @override
  Future<void> copyMonth(String fromMonth, String toMonth) {
    return _db.transaction(() async {
      final source = await (_db.select(_db.budgets)
            ..where((table) => table.month.equals(fromMonth)))
          .get();
      final income = await (_db.select(_db.budgetIncomes)
            ..where((table) => table.month.equals(fromMonth)))
          .getSingleOrNull();
      if (source.isEmpty && income == null) return;
      await save(
        month: toMonth,
        income: income?.amount ?? 0,
        allocations: {
          for (final row in source) row.categoryId: row.limitAmount,
        },
      );
    });
  }
}
