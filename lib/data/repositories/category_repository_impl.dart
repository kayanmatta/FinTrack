import 'package:drift/drift.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../database/app_database.dart';

/// Implementação Drift do repositório de categorias (camada de dados).
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._db);

  final AppDatabase _db;

  CategoryEntity _toEntity(Category row) {
    return CategoryEntity(
      id: row.id,
      name: row.name,
      icon: row.icon,
      color: row.color,
      type: row.type,
      isDefault: row.isDefault,
    );
  }

  @override
  Stream<List<CategoryEntity>> watchAll() {
    return _db
        .select(_db.categories)
        .watch()
        .map((rows) => [for (final row in rows) _toEntity(row)]);
  }

  @override
  Future<int> create({
    required String name,
    required String icon,
    required String color,
    required String type,
  }) {
    return _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            name: name,
            icon: icon,
            color: color,
            type: Value(type),
          ),
        );
  }

  @override
  Future<void> update(CategoryEntity category) {
    return (_db.update(_db.categories)
          ..where((table) => table.id.equals(category.id)))
        .write(
      CategoriesCompanion(
        name: Value(category.name),
        icon: Value(category.icon),
        color: Value(category.color),
        type: Value(category.type),
      ),
    );
  }

  @override
  Future<void> delete(int id) {
    return _db.transaction(() async {
      // Transações vinculadas ficam sem categoria em vez de quebrar o FK.
      await (_db.update(_db.transactions)
            ..where((table) => table.categoryId.equals(id)))
          .write(const TransactionsCompanion(categoryId: Value(null)));
      await (_db.delete(_db.categories)..where((table) => table.id.equals(id)))
          .go();
    });
  }
}
