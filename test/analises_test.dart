import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/core/utils/currency_utils.dart';
import 'package:fintrack/domain/entities/category_entity.dart';
import 'package:fintrack/domain/entities/transaction_entity.dart';
import 'package:fintrack/domain/repositories/category_repository.dart';
import 'package:fintrack/domain/repositories/transaction_repository.dart';
import 'package:fintrack/presentation/providers/category_provider.dart';
import 'package:fintrack/presentation/providers/transaction_provider.dart';
import 'package:fintrack/presentation/screens/analises_screen.dart';

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

const _monthNames = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

/// Dados relativos ao mês atual: receitas 4.000, despesas 1.200 (Moradia)
/// + 300 (Transporte); mês anterior: receitas 2.000 e despesa 1.000.
List<TransactionEntity> _seed() {
  final now = DateTime.now();
  final thisMonth = DateTime(now.year, now.month, 5);
  final previousMonth = DateTime(now.year, now.month - 1, 10);
  return [
    TransactionEntity(
      id: 1,
      type: 'receita',
      amount: 400000,
      categoryId: null,
      accountId: null,
      date: thisMonth,
      description: 'Salário',
      createdAt: thisMonth,
    ),
    TransactionEntity(
      id: 2,
      type: 'despesa',
      amount: 120000,
      categoryId: 1,
      accountId: null,
      date: thisMonth,
      description: 'Aluguel',
      createdAt: thisMonth,
    ),
    TransactionEntity(
      id: 3,
      type: 'despesa',
      amount: 30000,
      categoryId: 2,
      accountId: null,
      date: thisMonth,
      description: 'Uber',
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
  ];
}

Future<void> _pumpAnalises(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(
          FakeCategoryRepository([
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
          ]),
        ),
        transactionRepositoryProvider.overrideWithValue(
          FakeTransactionRepository(_seed()),
        ),
      ],
      child: MaterialApp(theme: AppTheme.dark, home: const AnalisesScreen()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('Exibe cards, ranking, resumo e insights do mês atual', (
    tester,
  ) async {
    final now = DateTime.now();
    await _pumpAnalises(tester);

    // Seletor de mês no cabeçalho.
    expect(
      find.text('${_monthNames[now.month - 1]} de ${now.year}'),
      findsOneWidget,
    );

    // Cards analíticos (S5-01).
    expect(find.text('Saldo'), findsOneWidget);
    expect(find.text('Receitas'), findsOneWidget);
    expect(find.text('Despesas'), findsOneWidget);
    expect(find.text('Economia'), findsOneWidget);
    expect(find.text('R\$ 3.500,00'), findsOneWidget);
    expect(find.text('R\$ 4.000,00'), findsOneWidget);
    expect(find.text('R\$ 1.500,00'), findsOneWidget);
    expect(find.text('R\$ 2.500,00'), findsOneWidget);

    // Ranking de maiores gastos (S5-02): valor aparece também no resumo.
    expect(find.text('Maiores gastos do mês'), findsOneWidget);
    expect(find.text('Aluguel'), findsWidgets);
    expect(find.text('R\$ 1.200,00'), findsNWidgets(2));
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('Uber'), findsOneWidget);
    expect(find.text('R\$ 300,00'), findsNWidgets(2));
    expect(find.text('20%'), findsOneWidget);

    // Resumo do mês (S5-04).
    final summaryHeader = find.text('Resumo do mês');
    await tester.dragUntilVisible(
      summaryHeader,
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    expect(find.text('Total de transações'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Maior despesa'), findsOneWidget);
    expect(find.text('Menor despesa'), findsOneWidget);
    expect(find.text('Média diária de gastos'), findsOneWidget);
    expect(
      find.text(formatCents((150000 / now.day).round())),
      findsOneWidget,
    );

    // Insights automáticos (S5-05).
    final insightsHeader = find.text('Insights para você');
    await tester.dragUntilVisible(
      insightsHeader,
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    expect(
      find.textContaining('a mais em Moradia em relação ao mês anterior'),
      findsOneWidget,
    );
    expect(
      find.textContaining('representam 80,0% da sua despesa total'),
      findsOneWidget,
    );
    expect(
      find.text('Sua economia do mês é de 62,5% da receita.'),
      findsOneWidget,
    );
  });

  testWidgets('Navega para o mês anterior e recalcula as métricas', (
    tester,
  ) async {
    final now = DateTime.now();
    final previous = DateTime(now.year, now.month - 1);
    await _pumpAnalises(tester);

    await tester.tap(find.byTooltip('Mês anterior'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('${_monthNames[previous.month - 1]} de ${previous.year}'),
      findsOneWidget,
    );
    // Mês anterior: receitas 2.000; despesa única de 1.000 aparece no
    // saldo, despesas, economia, ranking, maior e menor despesa.
    expect(find.text('R\$ 2.000,00'), findsOneWidget);
    expect(find.text('R\$ 1.000,00'), findsNWidgets(6));
    expect(find.text('100%'), findsOneWidget);

    // Volta ao mês atual pelo chevron direito.
    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('${_monthNames[now.month - 1]} de ${now.year}'),
      findsOneWidget,
    );
  });

  testWidgets('Filtra as análises por categoria (S5-07)', (tester) async {
    await _pumpAnalises(tester);

    await tester.tap(find.text('Todas categorias').first);
    await tester.pumpAndSettle();
    // byType compara runtimeType exato, então o genérico é obrigatório.
    await tester.tap(find.widgetWithText(PopupMenuItem<int?>, 'Moradia'));
    await tester.pumpAndSettle();

    // Só restam as despesas de Moradia: 1.200 no card, no ranking e no
    // resumo (maior e menor despesa).
    expect(find.text('Uber'), findsNothing);
    expect(find.text('R\$ 1.200,00'), findsNWidgets(4));
    expect(
      find.textContaining('representam 100,0% da sua despesa total'),
      findsOneWidget,
    );
    // Sem receitas no filtro, não há insight de economia.
    expect(find.textContaining('Sua economia do mês'), findsNothing);
  });
}
