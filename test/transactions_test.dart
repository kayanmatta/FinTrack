import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/data/database/app_database.dart';
import 'package:fintrack/data/repositories/category_repository_impl.dart';
import 'package:fintrack/data/repositories/transaction_repository_impl.dart';

void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = TransactionRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('Salva transação e lista mais recente primeiro', () async {
    // Categoria e conta de apoio para as FKs.
    final categories = CategoryRepositoryImpl(db);
    final categoryId = await categories.create(
      name: 'Mercado',
      icon: 'shopping_cart',
      color: '#EF4444',
      type: 'despesa',
    );

    await repository.create(
      type: 'despesa',
      amount: 4550,
      categoryId: categoryId,
      date: DateTime(2026, 8, 25),
      description: 'Compra da semana',
    );
    await repository.create(
      type: 'receita',
      amount: 300000,
      date: DateTime(2026, 8, 27),
    );

    final items = await repository.watchAll().first;
    expect(items, hasLength(2));
    expect(items.first.type, 'receita');
    expect(items.first.amount, 300000);
    expect(items.first.categoryId, isNull);
    expect(items.last.description, 'Compra da semana');
    expect(items.last.categoryId, categoryId);
  });

  test('Atualiza e exclui transação', () async {
    final id = await repository.create(
      type: 'despesa',
      amount: 1000,
      date: DateTime(2026, 8, 20),
      description: 'Original',
    );

    var items = await repository.watchAll().first;
    await repository.update(
      items.single.copyWith(amount: 2500, description: () => 'Editada'),
    );

    items = await repository.watchAll().first;
    expect(items.single.amount, 2500);
    expect(items.single.description, 'Editada');

    await repository.delete(id);
    items = await repository.watchAll().first;
    expect(items, isEmpty);
  });
}
