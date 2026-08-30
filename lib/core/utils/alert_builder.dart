import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import 'budget_metrics.dart';
import 'currency_utils.dart';
import 'finance_metrics.dart';
import 'financial_analytics.dart';
import 'goal_metrics.dart';

/// Construção determinística dos alertas da central de notificações (S8).
///
/// Função pura: recebe os dados já carregados e a data de referência,
/// sem banco, UI ou relógio global. Valores em centavos.

/// Variação mínima de gastos (em %) para gerar alerta (S8-02).
const double kSpendingIncreaseThreshold = 25;

/// Percentual do limite que dispara o aviso de orçamento (S8-03).
const double kBudgetWarningThreshold = 80;

/// Gera todos os alertas vigentes para o mês de [now] (S8-02 a S8-05).
///
/// [budgets] são os limites do mês atual; [contributedByGoal] mapeia o id
/// da meta para o total já aportado; [categoryNames] mapeia o id da
/// categoria para o nome exibido.
List<AlertEntity> buildAlerts({
  required List<TransactionEntity> transactions,
  required List<BudgetEntity> budgets,
  required List<GoalEntity> goals,
  required Map<int, int> contributedByGoal,
  required Map<int, String> categoryNames,
  DateTime? now,
}) {
  final month = now ?? DateTime.now();
  final alerts = <AlertEntity>[];
  alerts.addAll(_budgetAlerts(transactions, budgets, categoryNames, month));
  alerts.addAll(
    _variationAlerts(transactions, categoryNames, month),
  );
  alerts.addAll(_savingsAlert(transactions, month));
  alerts.addAll(_goalAlerts(goals, contributedByGoal));
  alerts.sort((a, b) => a.severity.index.compareTo(b.severity.index));
  return alerts;
}

/// Alertas de orçamento: aviso aos 80% e estouro acima de 100% (S8-03).
List<AlertEntity> _budgetAlerts(
  List<TransactionEntity> transactions,
  List<BudgetEntity> budgets,
  Map<int, String> categoryNames,
  DateTime month,
) {
  final spent = {
    for (final item in spendingByCategory(transactions, reference: month))
      item.categoryId: item.amount,
  };
  final monthKeyText = monthKey(month);
  final alerts = <AlertEntity>[];
  for (final budget in budgets) {
    if (budget.limitAmount <= 0) continue;
    final name = categoryNames[budget.categoryId] ?? 'Sem categoria';
    final spentAmount = spent[budget.categoryId] ?? 0;
    final percent = spentAmount / budget.limitAmount * 100;
    if (percent >= 100) {
      alerts.add(AlertEntity(
        key: 'orcamento-${budget.categoryId}-$monthKeyText',
        title: 'Orçamento estourado',
        message: AlertTemplates.budgetExceeded(name, percent),
        severity: AlertSeverity.danger,
      ));
    } else if (percent >= kBudgetWarningThreshold) {
      alerts.add(AlertEntity(
        key: 'orcamento-${budget.categoryId}-$monthKeyText',
        title: 'Orçamento',
        message: AlertTemplates.budgetReached(name, percent),
        severity: AlertSeverity.warning,
      ));
    }
  }
  return alerts;
}

/// Alertas de variação de gastos por categoria vs mês anterior (S8-02).
List<AlertEntity> _variationAlerts(
  List<TransactionEntity> transactions,
  Map<int, String> categoryNames,
  DateTime month,
) {
  final previous = DateTime(month.year, month.month - 1);
  final current = spendingByCategory(transactions, reference: month);
  final previousByCategory = {
    for (final item in spendingByCategory(transactions, reference: previous))
      item.categoryId: item.amount,
  };
  final monthKeyText = monthKey(month);
  return [
    for (final item in current)
      () {
        final previousAmount = previousByCategory[item.categoryId] ?? 0;
        final change = percentChange(item.amount, previousAmount);
        if (change == null || change < kSpendingIncreaseThreshold) {
          return null;
        }
        final name = categoryNames[item.categoryId] ?? 'Sem categoria';
        return AlertEntity(
          key: 'variacao-${item.categoryId}-$monthKeyText',
          title: 'Gastos em alta',
          message: AlertTemplates.spendingIncrease(name, change),
          severity: AlertSeverity.warning,
        );
      }(),
  ].whereType<AlertEntity>().toList();
}

/// Alerta de economia do mês com mensagem motivacional (S8-05).
List<AlertEntity> _savingsAlert(
  List<TransactionEntity> transactions,
  DateTime month,
) {
  final income = incomeOfMonth(transactions, month);
  if (income <= 0) return const [];
  final rate = savingsOfMonth(transactions, month) / income * 100;
  final (motivational, severity) = switch (rate) {
    >= 20 => ('Excelente! Você está construindo uma reserva sólida.',
        AlertSeverity.positive),
    >= 10 => ('Bom ritmo! Continue poupando todos os meses.',
        AlertSeverity.info),
    >= 0 => ('Margem apertada — tente reduzir alguns gastos.',
        AlertSeverity.warning),
    _ => ('Você gastou mais do que recebeu este mês.',
        AlertSeverity.danger),
  };
  return [
    AlertEntity(
      key: 'economia-${monthKey(month)}',
      title: 'Economia do mês',
      message: '${AlertTemplates.savingsRate(rate)} — $motivational',
      severity: severity,
    ),
  ];
}

/// Alertas de metas ainda não concluídas (S8-04).
List<AlertEntity> _goalAlerts(
  List<GoalEntity> goals,
  Map<int, int> contributedByGoal,
) {
  return [
    for (final goal in goals)
      if (goal.id != null &&
          !isGoalCompleted(
            targetAmount: goal.targetAmount,
            contributed: contributedByGoal[goal.id] ?? 0,
          ))
        AlertEntity(
          key: 'meta-${goal.id}',
          title: 'Meta: ${goal.name}',
          message:
              'Faltam ${formatCents(remainingAmount(
                targetAmount: goal.targetAmount,
                contributed: contributedByGoal[goal.id] ?? 0,
              ))} para atingir a meta ${goal.name}.',
          severity: AlertSeverity.info,
        ),
  ];
}
