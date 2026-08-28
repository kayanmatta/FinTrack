import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/domain/entities/transaction_entity.dart';
import 'package:fintrack/domain/repositories/transaction_repository.dart';
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
          transactionRepositoryProvider.overrideWithValue(
            FakeTransactionRepository([
              TransactionEntity(
                id: 1,
                type: 'receita',
                amount: 400000,
                categoryId: null,
                accountId: null,
                date: thisMonth,
                description: null,
                createdAt: thisMonth,
              ),
              TransactionEntity(
                id: 2,
                type: 'despesa',
                amount: 120000,
                categoryId: null,
                accountId: null,
                date: thisMonth,
                description: null,
                createdAt: thisMonth,
              ),
              TransactionEntity(
                id: 3,
                type: 'despesa',
                amount: 30000,
                categoryId: null,
                accountId: null,
                date: thisMonth,
                description: null,
                createdAt: thisMonth,
              ),
              TransactionEntity(
                id: 4,
                type: 'receita',
                amount: 200000,
                categoryId: null,
                accountId: null,
                date: previousMonth,
                description: null,
                createdAt: previousMonth,
              ),
              TransactionEntity(
                id: 5,
                type: 'despesa',
                amount: 100000,
                categoryId: null,
                accountId: null,
                date: previousMonth,
                description: null,
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

    // Valores: saldo 3.500, receitas 4.000, despesas 1.500, economia 2.500.
    expect(find.text('R\$ 3.500,00'), findsOneWidget);
    expect(find.text('R\$ 4.000,00'), findsOneWidget);
    expect(find.text('R\$ 1.500,00'), findsOneWidget);
    expect(find.text('R\$ 2.500,00'), findsOneWidget);

    // Variações percentuais vs mês anterior.
    expect(find.text('250,0% vs mês anterior'), findsOneWidget);
    expect(find.text('100,0% vs mês anterior'), findsOneWidget);
    expect(find.text('50,0% vs mês anterior'), findsOneWidget);
    expect(find.text('150,0% vs mês anterior'), findsOneWidget);
  });
}
