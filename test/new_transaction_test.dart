import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/domain/entities/account_entity.dart';
import 'package:fintrack/domain/entities/category_entity.dart';
import 'package:fintrack/domain/entities/transaction_entity.dart';
import 'package:fintrack/domain/repositories/account_repository.dart';
import 'package:fintrack/domain/repositories/category_repository.dart';
import 'package:fintrack/domain/repositories/transaction_repository.dart';
import 'package:fintrack/presentation/providers/account_provider.dart';
import 'package:fintrack/presentation/providers/category_provider.dart';
import 'package:fintrack/presentation/providers/transaction_provider.dart';
import 'package:fintrack/presentation/screens/transaction_form_screen.dart';

/// Repositório fake de categorias.
class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository(this._items);

  final List<CategoryEntity> _items;

  @override
  Stream<List<CategoryEntity>> watchAll() async* {
    yield List.of(_items);
  }

  @override
  Future<int> create({
    required String name,
    required String icon,
    required String color,
    required String type,
  }) async =>
      0;

  @override
  Future<void> update(CategoryEntity category) async {}

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> ensureDefaultCategories() async {}
}

/// Repositório fake de contas.
class FakeAccountRepository implements AccountRepository {
  FakeAccountRepository(this._items);

  final List<AccountEntity> _items;

  @override
  Stream<List<AccountEntity>> watchAll() async* {
    yield List.of(_items);
  }

  @override
  Future<int> create({
    required String name,
    required String type,
    required int initialBalance,
    required String color,
  }) async =>
      0;

  @override
  Future<void> update(AccountEntity account) async {}

  @override
  Future<void> delete(int id) async {}
}

/// Repositório fake de transações que registra as criações.
class FakeTransactionRepository implements TransactionRepository {
  final List<TransactionEntity> created = [];
  final List<TransactionEntity> updated = [];
  final List<int> deleted = [];
  int _nextId = 1;

  @override
  Stream<List<TransactionEntity>> watchAll() async* {
    yield List.of(created);
  }

  @override
  Future<int> create({
    required String type,
    required int amount,
    int? categoryId,
    int? accountId,
    required DateTime date,
    String? description,
  }) async {
    final id = _nextId++;
    created.add(
      TransactionEntity(
        id: id,
        type: type,
        amount: amount,
        categoryId: categoryId,
        accountId: accountId,
        date: date,
        description: description,
        createdAt: DateTime(2026, 8, 28),
      ),
    );
    return id;
  }

  @override
  Future<void> update(TransactionEntity transaction) async {
    updated.add(transaction);
  }

  @override
  Future<void> delete(int id) async {
    deleted.add(id);
  }
}

void main() {
  testWidgets('Cria despesa com categoria e valor', (tester) async {
    final transactions = FakeTransactionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(
            FakeCategoryRepository([
              const CategoryEntity(
                id: 1,
                name: 'Mercado',
                icon: 'shopping_cart',
                color: '#EF4444',
                type: 'despesa',
                isDefault: true,
              ),
              const CategoryEntity(
                id: 2,
                name: 'Salário',
                icon: 'more_horiz',
                color: '#10B981',
                type: 'receita',
                isDefault: false,
              ),
            ]),
          ),
          accountRepositoryProvider.overrideWithValue(
            FakeAccountRepository([
              AccountEntity(
                id: 1,
                name: 'Carteira',
                type: 'carteira',
                initialBalance: 0,
                color: '#6C2BD9',
                createdAt: DateTime(2026, 1, 1),
              ),
            ]),
          ),
          transactionRepositoryProvider.overrideWithValue(transactions),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const TransactionFormScreen(),
        ),
      ),
    );
    await tester.pump();

    // O tipo padrão é despesa: apenas a categoria Mercado aparece.
    expect(find.text('Mercado'), findsOneWidget);
    expect(find.text('Salário'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Valor'),
      '45,50',
    );
    await tester.tap(find.text('Mercado'));
    await tester.scrollUntilVisible(
      find.text('Salvar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // A tela fecha e a transação foi registrada.
    expect(find.text('Nova transação'), findsNothing);
    expect(transactions.created, hasLength(1));
    final saved = transactions.created.single;
    expect(saved.type, 'despesa');
    expect(saved.amount, 4550);
    expect(saved.categoryId, 1);
  });

  testWidgets('Edita e exclui uma transação existente', (tester) async {
    final transactions = FakeTransactionRepository();
    final original = TransactionEntity(
      id: 7,
      type: 'despesa',
      amount: 2000,
      categoryId: 1,
      accountId: null,
      date: DateTime(2026, 8, 20),
      description: 'Lanche',
      createdAt: DateTime(2026, 8, 20),
    );

    Widget buildApp() {
      return ProviderScope(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(
            FakeCategoryRepository([
              const CategoryEntity(
                id: 1,
                name: 'Mercado',
                icon: 'shopping_cart',
                color: '#EF4444',
                type: 'despesa',
                isDefault: true,
              ),
            ]),
          ),
          accountRepositoryProvider.overrideWithValue(
            FakeAccountRepository([]),
          ),
          transactionRepositoryProvider.overrideWithValue(transactions),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionFormScreen(initial: original),
                      ),
                    );
                  },
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Edição: valores pré-preenchidos e salvos via update.
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Editar transação'), findsOneWidget);
    expect(find.text('20,00'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Valor'),
      '25,00',
    );
    await tester.scrollUntilVisible(
      find.text('Salvar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(transactions.updated, hasLength(1));
    expect(transactions.updated.single.amount, 2500);
    expect(transactions.updated.single.id, 7);

    // Exclusão com confirmação.
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Excluir transação'), findsOneWidget);
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(transactions.deleted, [7]);
    expect(find.text('Editar transação'), findsNothing);
  });
}
