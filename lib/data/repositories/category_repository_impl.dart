import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../database/app_database.dart';

/// Categorias pré-cadastradas no primeiro uso (nome, ícone, cor).
const List<(String, String, String)> _defaultCategories = [
  ('Mercado', 'shopping_cart', '#EF4444'),
  ('Transporte', 'directions_car', '#3B82F6'),
  ('Lazer', 'sports_esports', '#F97316'),
  ('Saúde', 'favorite', '#10B981'),
  ('Casa', 'home', '#EC4899'),
  ('Educação', 'menu_book', '#8B5CF6'),
  ('Compras', 'shopping_bag', '#F59E0B'),
  ('Outros', 'more_horiz', '#64748B'),
];

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

  @override
  Future<void> ensureDefaultCategories() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seedFlagKey) == true) return;

    final existing = await _db.select(_db.categories).get();
    if (existing.isEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.categories,
          [
            for (final (name, icon, color) in _defaultCategories)
              CategoriesCompanion.insert(
                name: name,
                icon: icon,
                color: color,
                type: const Value('despesa'),
                isDefault: const Value(true),
              ),
          ],
        );
      });
    }
    await prefs.setBool(_seedFlagKey, true);
  }

  static const _seedFlagKey = 'seed.categories_done';
}
