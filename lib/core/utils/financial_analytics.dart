import 'dart:math';

import '../../domain/entities/transaction_entity.dart';
import 'finance_metrics.dart';

/// Fórmulas determinísticas da tela de Análises (Sprint 5).
///
/// Assim como [finance_metrics], todas as funções são puras: recebem
/// transações e uma data de referência, sem banco, UI ou relógio global.
/// Valores em centavos.

/// Formata um percentual no padrão pt-BR (ex.: 12.5 -> "12,5").
String formatPercentPt(double value) =>
    value.toStringAsFixed(1).replaceAll('.', ',');

/// Templates padronizados de alertas e insights (S5-06).
///
/// Textos reutilizáveis pela tela de análises (S5-05) e, no futuro,
/// pela central de notificações (S8).
class AlertTemplates {
  AlertTemplates._();

  /// "{categoria}: {variação}% vs mês anterior".
  static String categoryVariation(String category, double variation) =>
      '$category: ${formatPercentPt(variation)}% vs mês anterior';

  /// "Você gastou {X}% a mais em {categoria} em relação ao mês anterior."
  static String spendingIncrease(String category, double percent) =>
      'Você gastou ${formatPercentPt(percent)}% a mais em $category '
      'em relação ao mês anterior.';

  /// "Você gastou {X}% a menos em {categoria} em relação ao mês anterior."
  static String spendingDecrease(String category, double percent) =>
      'Você gastou ${formatPercentPt(percent)}% a menos em $category '
      'em relação ao mês anterior.';

  /// "Seus gastos com {categoria} representam {X}% da sua despesa total."
  static String categoryShare(String category, double percent) =>
      'Seus gastos com $category representam ${formatPercentPt(percent)}% '
      'da sua despesa total.';

  /// "Sua economia do mês é de {X}% da receita."
  static String savingsRate(double percent) =>
      'Sua economia do mês é de ${formatPercentPt(percent)}% da receita.';

  /// "Você atingiu {X}% do limite de {categoria}." (S6-03/S8-03)
  static String budgetReached(String category, double percent) =>
      'Você atingiu ${formatPercentPt(percent)}% do limite de $category.';

  /// "Você ultrapassou o limite de {categoria} ({X}%)." (S6-03/S8-03)
  static String budgetExceeded(String category, double percent) =>
      'Você ultrapassou o limite de $category (${formatPercentPt(percent)}%).';
}

/// Saldo acumulado até o final do mês de [reference].
int balanceUpTo(List<TransactionEntity> transactions, DateTime reference) {
  var balance = 0;
  for (final transaction in transactions) {
    final date = transaction.date;
    final beforeEndOfMonth = date.year < reference.year ||
        (date.year == reference.year && date.month <= reference.month);
    if (beforeEndOfMonth) {
      balance += transaction.isIncome ? transaction.amount : -transaction.amount;
    }
  }
  return balance;
}

/// As [count] maiores despesas do mês, ordenadas da maior para a menor
/// (S5-02), com percentual sobre o total de despesas do mês.
List<RankedExpense> topExpenses(
  List<TransactionEntity> transactions, {
  int count = 5,
  DateTime? reference,
}) {
  final month = reference ?? DateTime.now();
  final expenses = transactions
      .where(
        (transaction) =>
            transaction.type == 'despesa' &&
            _isSameMonth(transaction.date, month),
      )
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));
  final total = expenses.fold<int>(0, (sum, t) => sum + t.amount);
  return [
    for (final transaction in expenses.take(count))
      RankedExpense(
        description: transaction.description,
        categoryId: transaction.categoryId,
        amount: transaction.amount,
        percentage: total == 0
            ? 0
            : transaction.amount / total * 100,
      ),
  ];
}

/// Resumo do mês (S5-04): contagem, maior/menor despesa e média diária.
MonthSummary monthSummary(
  List<TransactionEntity> transactions, {
  DateTime? reference,
}) {
  final month = reference ?? DateTime.now();
  final inMonth = transactions
      .where((transaction) => _isSameMonth(transaction.date, month))
      .toList();
  final amounts = [
    for (final transaction in inMonth)
      if (transaction.type == 'despesa') transaction.amount,
  ];
  final totalExpenses = amounts.fold<int>(0, (sum, value) => sum + value);
  return MonthSummary(
    transactionCount: inMonth.length,
    largestExpense: amounts.isEmpty ? null : amounts.reduce(max),
    smallestExpense: amounts.isEmpty ? null : amounts.reduce(min),
    // Média diária considera os dias decorridos do mês de referência.
    dailyAverageExpenses: totalExpenses / month.day,
  );
}

/// Gera até 3 insights automáticos sobre o mês de [reference] (S5-05).
///
/// [categoryNames] mapeia id da categoria para o nome exibido; categorias
/// sem nome aparecem como "Sem categoria".
List<Insight> buildInsights(
  List<TransactionEntity> transactions, {
  Map<int, String> categoryNames = const {},
  DateTime? reference,
}) {
  final month = reference ?? DateTime.now();
  final previous = DateTime(month.year, month.month - 1);
  final insights = <Insight>[];

  // 1) Maior aumento de gasto por categoria vs mês anterior.
  final current = spendingByCategory(transactions, reference: month);
  final previousByCategory = {
    for (final item in spendingByCategory(transactions, reference: previous))
      item.categoryId: item.amount,
  };
  double? biggestIncrease;
  int? biggestCategoryId;
  for (final item in current) {
    final previousAmount = previousByCategory[item.categoryId] ?? 0;
    final change = percentChange(item.amount, previousAmount);
    if (change != null && change > 0 && change > (biggestIncrease ?? 0)) {
      biggestIncrease = change;
      biggestCategoryId = item.categoryId;
    }
  }
  if (biggestIncrease != null) {
    insights.add(Insight(
      message: AlertTemplates.spendingIncrease(
        _nameOf(categoryNames, biggestCategoryId),
        biggestIncrease,
      ),
      kind: InsightKind.warning,
    ));
  }

  // 2) Concentração: participação da maior categoria no total do mês.
  if (current.isNotEmpty) {
    insights.add(Insight(
      message: AlertTemplates.categoryShare(
        _nameOf(categoryNames, current.first.categoryId),
        current.first.percentage,
      ),
      kind: InsightKind.info,
    ));
  }

  // 3) Taxa de economia do mês (economia / receita).
  final income = incomeOfMonth(transactions, month);
  if (income > 0) {
    final rate = savingsOfMonth(transactions, month) / income * 100;
    insights.add(Insight(
      message: AlertTemplates.savingsRate(rate),
      kind: rate >= 20
          ? InsightKind.positive
          : rate >= 0
              ? InsightKind.info
              : InsightKind.warning,
    ));
  }

  return insights.take(3).toList();
}

String _nameOf(Map<int, String> categoryNames, int? categoryId) =>
    categoryId == null
        ? 'Sem categoria'
        : categoryNames[categoryId] ?? 'Sem categoria';

bool _isSameMonth(DateTime date, DateTime reference) =>
    date.year == reference.year && date.month == reference.month;

/// Despesa individual no ranking de maiores gastos do mês.
class RankedExpense {
  const RankedExpense({
    required this.description,
    required this.categoryId,
    required this.amount,
    required this.percentage,
  });

  final String? description;
  final int? categoryId;
  final int amount;
  final double percentage;
}

/// Indicadores do resumo do mês (S5-04).
class MonthSummary {
  const MonthSummary({
    required this.transactionCount,
    required this.largestExpense,
    required this.smallestExpense,
    required this.dailyAverageExpenses,
  });

  final int transactionCount;
  final int? largestExpense;
  final int? smallestExpense;

  /// Média diária de gastos em centavos (dias decorridos do mês).
  final double dailyAverageExpenses;
}

/// Natureza de um insight, para escolha de ícone/cor na UI.
enum InsightKind { warning, info, positive }

/// Insight automático exibido na tela de análises (S5-05).
class Insight {
  const Insight({required this.message, required this.kind});

  final String message;
  final InsightKind kind;
}
