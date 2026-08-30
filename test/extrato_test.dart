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

  testWidgets('Filtra por tipo, busca por texto e alterna para tabela', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

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

    // Filtro por tipo: só despesas.
    await tester.tap(find.text('Despesas'));
    await tester.pump();
    expect(find.text('+ R\$ 3.000,00'), findsNothing);
    expect(find.text('- R\$ 45,50'), findsOneWidget);

    // Busca por texto.
    await tester.tap(find.text('Todas'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Compra');
    await tester.pump();
    expect(find.text('Compra da semana'), findsOneWidget);
    expect(find.text('+ R\$ 3.000,00'), findsNothing);

    // Tabela: colunas e linha visível.
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.table_chart));
    await tester.pumpAndSettle();
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Valor'), findsOneWidget);
    expect(find.text('Compra da semana'), findsOneWidget);
  });

  testWidgets('Pagina o extrato em blocos de 100 com "Carregar mais"', (
    tester,
  ) async {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    final items = [
      for (var i = 0; i < 150; i++)
        TransactionEntity(
          id: i + 1,
          type: 'despesa',
          amount: 100 + i,
          categoryId: 1,
          accountId: null,
          date: base.subtract(Duration(days: i)),
          description: 'Compra $i',
          createdAt: base.subtract(Duration(days: i)),
        ),
    ];

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
            ]),
          ),
          accountRepositoryProvider.overrideWithValue(
            FakeAccountRepository([]),
          ),
          transactionRepositoryProvider.overrideWithValue(
            FakeTransactionRepository(items),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const ExtratoScreen(),
        ),
      ),
    );
    await tester.pump();

    // Primeira página termina na 100ª transação (Compra 99, datas distintas
    // em ordem decrescente); a 150ª ainda não existe na lista.
    await tester.scrollUntilVisible(
      find.text('Compra 99'),
      600,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Compra 149'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Carregar mais transações'),
      600,
      scrollable: find.byType(Scrollable).last,
    );

    // Carrega o restante e a última transação aparece.
    await tester.tap(find.text('Carregar mais transações'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Compra 149'),
      600,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Carregar mais transações'), findsNothing);
  });

  testWidgets('Confirma edição com snackbar "Transação salva."', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

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

    // Abre a transação para edição e salva.
    await tester.tap(find.text('Compra da semana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Transação salva.'), findsOneWidget);
  });
}
