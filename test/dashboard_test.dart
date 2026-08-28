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
import 'package:fintrack/presentation/screens/dashboard_screen.dart';

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
  testWidgets('Exibe os 4 cards de resumo com variação vs mês anterior', (
    tester,
  ) async {
    // Dados relativos ao mês atual para as fórmulas capturarem os valores.
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 5);
    final previousMonth = DateTime(now.year, now.month - 1, 10);

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
                name: 'Transporte',
                icon: 'directions_car',
                color: '#3B82F6',
                type: 'despesa',
                isDefault: true,
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
                type: 'receita',
                amount: 400000,
                categoryId: null,
                accountId: null,
                date: thisMonth,
                description: 'Salário mensal',
                createdAt: thisMonth,
              ),
              TransactionEntity(
                id: 2,
                type: 'despesa',
                amount: 120000,
                categoryId: 1,
                accountId: null,
                date: thisMonth,
                description: 'Compras do mês',
                createdAt: thisMonth,
              ),
              TransactionEntity(
                id: 3,
                type: 'despesa',
                amount: 30000,
                categoryId: 2,
                accountId: null,
                date: thisMonth,
                description: 'Aplicativo de corrida',
                createdAt: thisMonth,
              ),
              TransactionEntity(
                id: 4,
                type: 'receita',
                amount: 200000,
                categoryId: null,
                accountId: null,
                date: previousMonth,
                description: 'Freelance',
                createdAt: previousMonth,
              ),
              TransactionEntity(
                id: 5,
                type: 'despesa',
                amount: 100000,
                categoryId: 1,
                accountId: null,
                date: previousMonth,
                description: 'Aluguel',
                createdAt: previousMonth,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Títulos dos 4 cards.
    expect(find.text('Saldo atual'), findsOneWidget);
    expect(find.text('Receitas'), findsOneWidget);
    expect(find.text('Despesas'), findsOneWidget);
    expect(find.text('Economia'), findsOneWidget);

    // Valores: saldo 3.500, receitas 4.000, despesas 1.500 (também no
    // centro do donut), economia 2.500.
    expect(find.text('R\$ 3.500,00'), findsOneWidget);
    expect(find.text('R\$ 4.000,00'), findsOneWidget);
    expect(find.text('R\$ 1.500,00'), findsNWidgets(2));
    expect(find.text('R\$ 2.500,00'), findsOneWidget);

    // Variações percentuais vs mês anterior.
    expect(find.text('250,0% vs mês anterior'), findsOneWidget);
    expect(find.text('100,0% vs mês anterior'), findsOneWidget);
    expect(find.text('50,0% vs mês anterior'), findsOneWidget);
    expect(find.text('150,0% vs mês anterior'), findsOneWidget);

    // Seções de gráficos e últimas transações.
    expect(find.text('Gastos por categoria'), findsOneWidget);
    expect(find.text('Evolução de despesas'), findsOneWidget);

    // Donut: legenda com nomes, valores e percentuais (os percentuais
    // das fatias são pintados no canvas, então verificamos a legenda).
    expect(find.text('Mercado'), findsWidgets);
    expect(find.text('Transporte'), findsWidgets);
    expect(find.text('R\$ 1.200,00'), findsOneWidget);
    // Valor aparece no card de Despesas e no centro do donut.
    expect(find.text('R\$ 1.500,00'), findsNWidgets(2));
    expect(find.text('R\$ 300,00'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('20%'), findsOneWidget);

    // Últimas transações: rola até a seção e verifica as 5 mais recentes.
    final latestHeader = find.text('Últimas transações');
    await tester.dragUntilVisible(
      latestHeader,
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    expect(latestHeader, findsOneWidget);
    expect(find.text('Salário mensal'), findsOneWidget);
    expect(find.text('Compras do mês'), findsOneWidget);
    expect(find.text('Aplicativo de corrida'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
    expect(find.text('Aluguel'), findsOneWidget);
  });
}
