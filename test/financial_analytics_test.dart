import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/utils/financial_analytics.dart';
import 'package:fintrack/domain/entities/transaction_entity.dart';

/// Transações fixas com datas absolutas para testes determinísticos.
List<TransactionEntity> _seed() {
  final agosto = DateTime(2026, 8, 5);
  final julho = DateTime(2026, 7, 10);
  return [
    TransactionEntity(
      id: 1,
      type: 'receita',
      amount: 400000,
      categoryId: null,
      accountId: null,
      date: agosto,
      description: 'Salário',
      createdAt: agosto,
    ),
    TransactionEntity(
      id: 2,
      type: 'despesa',
      amount: 120000,
      categoryId: 1,
      accountId: null,
      date: DateTime(2026, 8, 10),
      description: 'Aluguel',
      createdAt: DateTime(2026, 8, 10),
    ),
    TransactionEntity(
      id: 3,
      type: 'despesa',
      amount: 30000,
      categoryId: 2,
      accountId: null,
      date: DateTime(2026, 8, 12),
      description: 'Uber',
      createdAt: DateTime(2026, 8, 12),
    ),
    TransactionEntity(
      id: 4,
      type: 'receita',
      amount: 200000,
      categoryId: null,
      accountId: null,
      date: julho,
      description: 'Freelance',
      createdAt: julho,
    ),
    TransactionEntity(
      id: 5,
      type: 'despesa',
      amount: 100000,
      categoryId: 1,
      accountId: null,
      date: julho,
      description: 'Aluguel',
      createdAt: julho,
    ),
  ];
}

void main() {
  final reference = DateTime(2026, 8, 20);

  test('balanceUpTo acumula até o final do mês de referência', () {
    expect(balanceUpTo(_seed(), reference), 350000);
    expect(balanceUpTo(_seed(), DateTime(2026, 7, 31)), 100000);
    expect(balanceUpTo(_seed(), DateTime(2026, 6, 30)), 0);
  });

  test('topExpenses ordena e calcula percentual sobre o total', () {
    final ranking = topExpenses(_seed(), reference: reference);
    expect(ranking.length, 2);
    expect(ranking[0].description, 'Aluguel');
    expect(ranking[0].amount, 120000);
    expect(ranking[0].percentage, closeTo(80, 0.01));
    expect(ranking[1].description, 'Uber');
    expect(ranking[1].percentage, closeTo(20, 0.01));
  });

  test('monthSummary conta transações e calcula média diária', () {
    final summary = monthSummary(_seed(), reference: reference);
    expect(summary.transactionCount, 3);
    expect(summary.largestExpense, 120000);
    expect(summary.smallestExpense, 30000);
    // 150.000 centavos / 20 dias decorridos = 7.500 centavos/dia.
    expect(summary.dailyAverageExpenses, closeTo(7500, 0.01));
  });

  test('AlertTemplates gera textos padronizados (S5-06)', () {
    expect(
      AlertTemplates.categoryVariation('Moradia', 20),
      'Moradia: 20,0% vs mês anterior',
    );
    expect(
      AlertTemplates.spendingIncrease('Moradia', 20),
      'Você gastou 20,0% a mais em Moradia em relação ao mês anterior.',
    );
    expect(
      AlertTemplates.categoryShare('Moradia', 80),
      'Seus gastos com Moradia representam 80,0% da sua despesa total.',
    );
    expect(
      AlertTemplates.savingsRate(62.5),
      'Sua economia do mês é de 62,5% da receita.',
    );
  });

  test('buildInsights gera os 3 cards automáticos (S5-05)', () {
    final insights = buildInsights(
      _seed(),
      categoryNames: const {1: 'Moradia', 2: 'Transporte'},
      reference: reference,
    );
    expect(insights.length, 3);
    expect(
      insights[0].message,
      'Você gastou 20,0% a mais em Moradia em relação ao mês anterior.',
    );
    expect(insights[0].kind, InsightKind.warning);
    expect(
      insights[1].message,
      'Seus gastos com Moradia representam 80,0% da sua despesa total.',
    );
    expect(insights[1].kind, InsightKind.info);
    expect(
      insights[2].message,
      'Sua economia do mês é de 62,5% da receita.',
    );
    expect(insights[2].kind, InsightKind.positive);
  });

  test('buildInsights retorna vazio sem despesas no mês', () {
    final insights = buildInsights(
      _seed(),
      categoryNames: const {1: 'Moradia'},
      reference: DateTime(2026, 6, 15),
    );
    expect(insights, isEmpty);
  });
}
