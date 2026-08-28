import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

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
import 'package:fintrack/presentation/screens/extrato_screen.dart';

/// Repositório fake de transações (lista fixa).
class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository(this._items);

  final List<TransactionEntity> _items;

  @override
  Stream<List<TransactionEntity>> watchAll() async* {
    yield List.of(_items);
  }

  @override
  Future<int> create({
    required String type,
    required int amount,
    int? categoryId,
    int? accountId,
    required DateTime date,
    String? description,
  }) async =>
      0;

  @override
  Future<void> update(TransactionEntity transaction) async {}

  @override
  Future<void> delete(int id) async {}
}

/// Repositório fake de categorias (lista fixa).
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

/// Repositório fake de contas (lista fixa).
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

void main() {
  testWidgets('Agrupa transações por dia (Hoje, Ontem, data)', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final older = today.subtract(const Duration(days: 3));

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
            FakeAccountRepository([]),
          ),
          transactionRepositoryProvider.overrideWithValue(
            FakeTransactionRepository([
              TransactionEntity(
                id: 1,
                type: 'despesa',
                amount: 4550,
                categoryId: 1,
                accountId: null,
                date: today,
                description: 'Compra da semana',
                createdAt: today,
              ),
              TransactionEntity(
                id: 2,
                type: 'receita',
                amount: 300000,
                categoryId: 2,
                accountId: null,
                date: yesterday,
                description: null,
                createdAt: yesterday,
              ),
              TransactionEntity(
                id: 3,
                type: 'despesa',
                amount: 1200,
                categoryId: 1,
                accountId: null,
                date: older,
                description: 'Padaria',
                createdAt: older,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const ExtratoScreen(),
        ),
      ),
    );
    await tester.pump();

    // Cabeçalhos de agrupamento.
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Ontem'), findsOneWidget);
    expect(
      find.text(DateFormat('dd/MM/yyyy').format(older)),
      findsOneWidget,
    );

    // Valores com sinal e cor por tipo.
    expect(find.text('- R\$ 45,50'), findsOneWidget);
    expect(find.text('+ R\$ 3.000,00'), findsOneWidget);

    // Descrição quando existe; nome da categoria como fallback.
    expect(find.text('Compra da semana'), findsOneWidget);
    expect(find.text('Padaria'), findsOneWidget);
  });
}
