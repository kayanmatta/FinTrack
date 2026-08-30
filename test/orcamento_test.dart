import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/core/utils/budget_metrics.dart';
import 'package:fintrack/core/utils/financial_analytics.dart';
import 'package:fintrack/domain/entities/budget_entity.dart';
import 'package:fintrack/domain/entities/category_entity.dart';
import 'package:fintrack/domain/entities/transaction_entity.dart';
import 'package:fintrack/domain/repositories/budget_repository.dart';
import 'package:fintrack/domain/repositories/category_repository.dart';
import 'package:fintrack/domain/repositories/transaction_repository.dart';
import 'package:fintrack/presentation/providers/budget_provider.dart';
import 'package:fintrack/presentation/providers/category_provider.dart';
import 'package:fintrack/presentation/providers/transaction_provider.dart';
import 'package:fintrack/presentation/screens/orcamento_screen.dart';

/// Repositório fake de orçamento com estado mutável e streams reativos.
class FakeBudgetRepository implements BudgetRepository {
  FakeBudgetRepository({
    Map<String, int>? incomes,
    Map<String, Map<int, int>>? allocations,
  })  : _incomes = {...?incomes},
        _allocations = {...?allocations};

  final Map<String, int> _incomes;
  final Map<String, Map<int, int>> _allocations;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  List<BudgetEntity> _budgetsOf(String month) => [
        for (final entry
            in (_allocations[month] ?? const <int, int>{}).entries)
          BudgetEntity(
            categoryId: entry.key,
            month: month,
            limitAmount: entry.value,
          ),
      ];

  @override
  Stream<List<BudgetEntity>> watchMonth(String month) async* {
    yield _budgetsOf(month);
    await for (final _ in _changes.stream) {
      yield _budgetsOf(month);
    }
  }

  @override
  Stream<int?> watchIncome(String month) async* {
    yield _incomes[month];
    await for (final _ in _changes.stream) {
      yield _incomes[month];
    }
  }

  @override
  Future<void> save({
    required String month,
    required int income,
    required Map<int, int> allocations,
  }) async {
    _incomes[month] = income;
    _allocations[month] = {
      for (final entry in allocations.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
    _changes.add(null);
  }

  @override
  Future<void> copyMonth(String fromMonth, String toMonth) async {
    if (_incomes[fromMonth] == null && !_allocations.containsKey(fromMonth)) {
      return;
    }
    await save(
      month: toMonth,
      income: _incomes[fromMonth] ?? 0,
      allocations: Map.of(_allocations[fromMonth] ?? const {}),
    );
  }
}

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

final _categories = [
  const CategoryEntity(
    id: 1,
    name: 'Moradia',
    icon: 'home',
    color: '#9F67FF',
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
  const CategoryEntity(
    id: 3,
    name: 'Salário',
    icon: 'payments',
    color: '#22C55E',
    type: 'receita',
    isDefault: true,
  ),
];

/// Despesa auxiliar no mês atual.
TransactionEntity _expense(int id, int categoryId, int amount) {
  final now = DateTime.now();
  final date = DateTime(now.year, now.month, 5);
  return TransactionEntity(
    id: id,
    type: 'despesa',
    amount: amount,
    categoryId: categoryId,
    accountId: null,
    date: date,
    description: null,
    createdAt: date,
  );
}

Future<void> _pumpOrcamento(
  WidgetTester tester, {
  required FakeBudgetRepository budgets,
  List<TransactionEntity> transactions = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        budgetRepositoryProvider.overrideWithValue(budgets),
        categoryRepositoryProvider.overrideWithValue(
          FakeCategoryRepository(_categories),
        ),
        transactionRepositoryProvider.overrideWithValue(
          FakeTransactionRepository(transactions),
        ),
      ],
      child: MaterialApp(theme: AppTheme.dark, home: const OrcamentoScreen()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Digita no campo de alocação da linha da categoria [name].
Future<void> _enterAllocation(
  WidgetTester tester,
  String name,
  String value,
) async {
  final row = find
      .ancestor(of: find.text(name), matching: find.byType(Row))
      .first;
  await tester.enterText(
    find.descendant(of: row, matching: find.byType(TextFormField)),
    value,
  );
}

void main() {
  testWidgets('Exibe formulário sem orçamento e salva a definição (S6-01)', (
    tester,
  ) async {
    await _pumpOrcamento(tester, budgets: FakeBudgetRepository());

    expect(find.text('Orçamento'), findsOneWidget);
    expect(
      find.text('Defina sua renda mensal e distribua entre as categorias.'),
      findsOneWidget,
    );
    expect(find.text('Salvar orçamento'), findsOneWidget);
    // Somente categorias de despesa aparecem no formulário.
    expect(find.text('Moradia'), findsOneWidget);
    expect(find.text('Salário'), findsNothing);

    // Campo de renda é o primeiro do formulário.
    await tester.enterText(find.byType(TextFormField).first, '4000,00');
    await _enterAllocation(tester, 'Moradia', '1500,00');
    await tester.pump();
    expect(find.text('Não alocado: R\$ 2.500,00'), findsOneWidget);

    await tester.tap(find.text('Salvar orçamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Sai do formulário e mostra os totais e a barra da categoria (S6-02/05).
    expect(find.text('Alocado'), findsOneWidget);
    expect(find.text('Gasto'), findsOneWidget);
    expect(find.text('Disponível'), findsOneWidget);
    expect(find.text('R\$ 1.500,00'), findsNWidgets(2));
    expect(find.text('R\$ 0,00'), findsOneWidget);
    expect(find.text('R\$ 0,00 de R\$ 1.500,00'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Restam R\$ 1.500,00'), findsOneWidget);
    expect(find.byTooltip('Ajustar orçamento'), findsOneWidget);
  });

  testWidgets('Bloqueia salvar sem renda informada', (tester) async {
    await _pumpOrcamento(tester, budgets: FakeBudgetRepository());

    await tester.tap(find.text('Salvar orçamento'));
    await tester.pump();
    expect(
      find.text('Informe uma renda maior que zero.'),
      findsOneWidget,
    );
    // Continua no formulário.
    expect(find.text('Salvar orçamento'), findsOneWidget);
  });

  testWidgets('Mostra progresso, alertas e totais do mês (S6-02..S6-05)', (
    tester,
  ) async {
    final now = DateTime.now();
    final key = monthKey(DateTime(now.year, now.month));
    await _pumpOrcamento(
      tester,
      budgets: FakeBudgetRepository(
        incomes: {key: 400000},
        allocations: {key: {1: 150000, 2: 50000}},
      ),
      transactions: [_expense(1, 1, 120000), _expense(2, 2, 60000)],
    );

    // Totais gerais do mês.
    expect(find.text('R\$ 2.000,00'), findsOneWidget);
    expect(find.text('R\$ 1.800,00'), findsOneWidget);
    expect(find.text('R\$ 200,00'), findsOneWidget);

    // Alertas de 80% e 100% (S6-03).
    expect(
      find.text(AlertTemplates.budgetReached('Moradia', 80.0)),
      findsOneWidget,
    );
    expect(
      find.text(AlertTemplates.budgetExceeded('Transporte', 120.0)),
      findsOneWidget,
    );

    // Barras de progresso ordenadas do maior para o menor percentual.
    expect(find.text('R\$ 1.200,00 de R\$ 1.500,00'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('Restam R\$ 300,00'), findsOneWidget);
    expect(find.text('R\$ 600,00 de R\$ 500,00'), findsOneWidget);
    expect(find.text('120%'), findsOneWidget);
    expect(find.text('Excedeu R\$ 100,00'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));

    // Ajustar orçamento abre o formulário preenchido; cancelar volta.
    await tester.tap(find.byTooltip('Ajustar orçamento'));
    await tester.pump();
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('4000,00'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pump();
    expect(find.text('Alocado'), findsOneWidget);
  });

  testWidgets('Copia o orçamento do mês anterior (S6-06)', (tester) async {
    final now = DateTime.now();
    final previousKey = monthKey(DateTime(now.year, now.month - 1));
    await _pumpOrcamento(
      tester,
      budgets: FakeBudgetRepository(
        incomes: {previousKey: 300000},
        allocations: {previousKey: {1: 90000}},
      ),
    );

    expect(
      find.text('Copiar orçamento do mês anterior'),
      findsOneWidget,
    );
    await tester.tap(find.text('Copiar orçamento do mês anterior'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Orçamento copiado aparece na visão de progresso.
    expect(find.text('R\$ 900,00'), findsNWidgets(2));
    expect(find.text('Restam R\$ 900,00'), findsOneWidget);
  });
}
