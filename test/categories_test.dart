import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/domain/entities/category_entity.dart';
import 'package:fintrack/domain/repositories/category_repository.dart';
import 'package:fintrack/presentation/providers/category_provider.dart';
import 'package:fintrack/presentation/screens/categories_screen.dart';

/// Repositório fake em memória para os testes de UI.
class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository(List<CategoryEntity> seed)
      : _items = List.of(seed);

  final List<CategoryEntity> _items;
  final _controller = StreamController<List<CategoryEntity>>.broadcast();
  int _nextId = 100;

  void _emit() => _controller.add(List.of(_items));

  @override
  Stream<List<CategoryEntity>> watchAll() async* {
    yield List.of(_items);
    yield* _controller.stream;
  }

  @override
  Future<int> create({
    required String name,
    required String icon,
    required String color,
    required String type,
  }) async {
    final id = _nextId++;
    _items.add(
      CategoryEntity(
        id: id,
        name: name,
        icon: icon,
        color: color,
        type: type,
        isDefault: false,
      ),
    );
    _emit();
    return id;
  }

  @override
  Future<void> update(CategoryEntity category) async {
    final index = _items.indexWhere((item) => item.id == category.id);
    if (index >= 0) _items[index] = category;
    _emit();
  }

  @override
  Future<void> delete(int id) async {
    _items.removeWhere((item) => item.id == id);
    _emit();
  }
}

void main() {
  testWidgets('Lista categorias e cria nova categoria', (tester) async {
    final repository = FakeCategoryRepository(const [
      CategoryEntity(
        id: 1,
        name: 'Mercado',
        icon: 'shopping_cart',
        color: '#10B981',
        type: 'despesa',
        isDefault: true,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const CategoriesScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Mercado'), findsOneWidget);

    // Cria uma nova categoria pelo diálogo.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Lazer');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Lazer'), findsOneWidget);

    // Exclui a categoria padrão com confirmação.
    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: find.text('Mercado'),
          matching: find.byType(ListTile),
        ),
        matching: find.byIcon(Icons.delete_outline),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Mercado'), findsNothing);
  });
}
