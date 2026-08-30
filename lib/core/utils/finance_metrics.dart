import '../../domain/entities/transaction_entity.dart';

/// Fórmulas determinísticas de métricas financeiras (S4-05).
///
/// Todas as funções são puras: recebem transações e uma data de referência,
/// sem dependência de banco, UI ou relógio global. Valores em centavos.

/// Total de receitas dentro do mês de [reference].
int incomeOfMonth(List<TransactionEntity> transactions, DateTime reference) =>
    _sumByType(transactions, reference, 'receita');

/// Total de despesas dentro do mês de [reference].
int expensesOfMonth(
  List<TransactionEntity> transactions,
  DateTime reference,
) => _sumByType(transactions, reference, 'despesa');

/// Economia do mês de [reference]: receitas - despesas.
int savingsOfMonth(List<TransactionEntity> transactions, DateTime reference) =>
    incomeOfMonth(transactions, reference) -
    expensesOfMonth(transactions, reference);

/// Saldo acumulado de todas as transações: receitas - despesas.
int totalBalance(List<TransactionEntity> transactions) {
  var balance = 0;
  for (final transaction in transactions) {
    balance += transaction.isIncome ? transaction.amount : -transaction.amount;
  }
  return balance;
}

/// Variação percentual de [current] em relação a [previous].
///
/// Retorna `null` quando o mês anterior é zero (variação indefinida).
double? percentChange(int current, int previous) {
  if (previous == 0) return null;
  return (current - previous) / previous * 100;
}

/// Resumo dos 4 cards do dashboard para o mês de [reference].
DashboardMetrics dashboardMetrics(
  List<TransactionEntity> transactions, {
  DateTime? reference,
}) {
  final month = reference ?? DateTime.now();
  final previous = DateTime(month.year, month.month - 1);

  final income = incomeOfMonth(transactions, month);
  final expenses = expensesOfMonth(transactions, month);
  final previousIncome = incomeOfMonth(transactions, previous);
  final previousExpenses = expensesOfMonth(transactions, previous);

  final balance = totalBalance(transactions);
  // Saldo ao final do mês anterior = saldo atual - resultado deste mês.
  final previousBalance = balance - (income - expenses);

  return DashboardMetrics(
    balance: balance,
    balanceChange: percentChange(balance, previousBalance),
    income: income,
    incomeChange: percentChange(income, previousIncome),
    expenses: expenses,
    expensesChange: percentChange(expenses, previousExpenses),
    savings: income - expenses,
    savingsChange: percentChange(
      income - expenses,
      previousIncome - previousExpenses,
    ),
  );
}

/// Gastos por categoria no mês de [reference], ordenados do maior ao menor.
List<CategorySpending> spendingByCategory(
  List<TransactionEntity> transactions, {
  DateTime? reference,
}) {
  final month = reference ?? DateTime.now();
  final totals = <int?, int>{};
  var grandTotal = 0;
  for (final transaction in transactions) {
    if (transaction.type != 'despesa' || !_isSameMonth(transaction.date, month)) {
      continue;
    }
    totals[transaction.categoryId] =
        (totals[transaction.categoryId] ?? 0) + transaction.amount;
    grandTotal += transaction.amount;
  }
  final result = [
    for (final entry in totals.entries)
      CategorySpending(
        categoryId: entry.key,
        amount: entry.value,
        percentage: grandTotal == 0 ? 0 : entry.value / grandTotal * 100,
      ),
  ];
  result.sort((a, b) => b.amount.compareTo(a.amount));
  return result;
}

/// Evolução mensal de despesas dos últimos [months] meses,
/// do mais antigo ao mais recente (o mês de [reference] é o último).
List<MonthlyTotal> expenseEvolution(
  List<TransactionEntity> transactions, {
  int months = 6,
  DateTime? reference,
}) {
  final end = reference ?? DateTime.now();
  return [
    for (var i = months - 1; i >= 0; i--)
      MonthlyTotal(
        month: DateTime(end.year, end.month - i),
        amount: expensesOfMonth(transactions, DateTime(end.year, end.month - i)),
      ),
  ];
}

/// As [count] transações mais recentes (data desc, desempate por criação).
List<TransactionEntity> latestTransactions(
  List<TransactionEntity> transactions, {
  int count = 5,
}) {
  final sorted = [...transactions]
    ..sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });
  return sorted.take(count).toList();
}

int _sumByType(
  List<TransactionEntity> transactions,
  DateTime reference,
  String type,
) {
  var total = 0;
  for (final transaction in transactions) {
    if (transaction.type == type && _isSameMonth(transaction.date, reference)) {
      total += transaction.amount;
    }
  }
  return total;
}

bool _isSameMonth(DateTime date, DateTime reference) =>
    date.year == reference.year && date.month == reference.month;

/// Métricas dos 4 cards do dashboard (valores em centavos).
class DashboardMetrics {
  const DashboardMetrics({
    required this.balance,
    required this.balanceChange,
    required this.income,
    required this.incomeChange,
    required this.expenses,
    required this.expensesChange,
    required this.savings,
    required this.savingsChange,
  });

  final int balance;
  final double? balanceChange;
  final int income;
  final double? incomeChange;
  final int expenses;
  final double? expensesChange;
  final int savings;
  final double? savingsChange;
}

/// Total gasto em uma categoria no mês, com percentual sobre o total.
class CategorySpending {
  const CategorySpending({
    required this.categoryId,
    required this.amount,
    required this.percentage,
  });

  final int? categoryId;
  final int amount;
  final double percentage;
}

/// Total de despesas de um mês.
class MonthlyTotal {
  const MonthlyTotal({required this.month, required this.amount});

  final DateTime month;
  final int amount;
}
