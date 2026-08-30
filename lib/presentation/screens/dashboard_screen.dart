import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/finance_metrics.dart';
import '../../core/utils/financial_analytics.dart';
import '../../core/utils/goal_metrics.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/expense_line_chart.dart';
import '../widgets/summary_card.dart';
import 'metas_screen.dart';
import 'transaction_form_screen.dart';

/// Nomes dos meses em português (sem dependência de locale do intl).
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

/// Tela inicial com resumo financeiro, gráficos e últimas transações (S4).
///
/// Desktop: fundo claro com cards escuros (mockup img1).
/// Mobile: fundo escuro com card hero em gradiente roxo (mockup img2).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);

    return transactions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
      data: (items) {
        final categoriesById = {
          for (final c in categories.valueOrNull ?? <CategoryEntity>[])
            c.id: c,
        };
        final accountsById = {
          for (final a in accounts.valueOrNull ?? <AccountEntity>[]) a.id: a,
        };
        return LayoutBuilder(
          builder: (context, constraints) {
            // 468 = 700 (breakpoint do shell) - 232 (largura da sidebar):
            // quando o HomeShell está no modo desktop, o dashboard também fica.
            if (constraints.maxWidth >= 468) {
              return _DesktopDashboard(
                items: items,
                categoriesById: categoriesById,
                accountsById: accountsById,
              );
            }
            return _MobileDashboard(
              items: items,
              categoriesById: categoriesById,
              accountsById: accountsById,
            );
          },
        );
      },
    );
  }
}

/// Layout desktop do dashboard (mockup img1): fundo claro + cards escuros.
class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({
    required this.items,
    required this.categoriesById,
    required this.accountsById,
  });

  final List<TransactionEntity> items;
  final Map<int, CategoryEntity> categoriesById;
  final Map<int, AccountEntity> accountsById;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final metrics = dashboardMetrics(items, reference: now);
    final spending = spendingByCategory(items, reference: now);
    final evolution = expenseEvolution(items, reference: now);
    final latest = latestTransactions(items);
    final lastDay = DateTime(now.year, now.month + 1, 0).day;

    return Container(
      color: AppColors.canvasLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Visão geral das suas finanças',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDarkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.textDarkSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '1 – $lastDay de ${_monthNames[now.month - 1]}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SummaryCards(metrics: metrics),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ChartCard(
                    title: 'Gastos por categoria',
                    child: CategoryDonutChart(
                      spending: spending,
                      categoriesById: categoriesById,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ChartCard(
                    title: 'Evolução de despesas',
                    child: SizedBox(
                      height: 220,
                      child: ExpenseLineChart(evolution: evolution),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _LatestCard(
                    transactions: latest,
                    categoriesById: categoriesById,
                    accountsById: accountsById,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _GoalsCard()),
              ],
            ),
            const SizedBox(height: 16),
            _InsightsStrip(items: items, categoriesById: categoriesById),
          ],
        ),
      ),
    );
  }
}

/// Layout mobile do dashboard (mockup img2): hero gradiente + mini cards.
class _MobileDashboard extends StatefulWidget {
  const _MobileDashboard({
    required this.items,
    required this.categoriesById,
    required this.accountsById,
  });

  final List<TransactionEntity> items;
  final Map<int, CategoryEntity> categoriesById;
  final Map<int, AccountEntity> accountsById;

  @override
  State<_MobileDashboard> createState() => _MobileDashboardState();
}

class _MobileDashboardState extends State<_MobileDashboard> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final metrics = dashboardMetrics(widget.items, reference: now);
    final spending = spendingByCategory(widget.items, reference: now);
    final evolution = expenseEvolution(widget.items, reference: now);
    final latest = latestTransactions(widget.items);
    final savingsRate = metrics.income > 0
        ? metrics.savings / metrics.income * 100
        : null;

    return Container(
      color: AppColors.backgroundDark,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeroBalanceCard(
            metrics: metrics,
            evolution: evolution,
            hidden: _hidden,
            onToggle: () => setState(() => _hidden = !_hidden),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniCard(
                  title: 'Receitas',
                  value: formatCents(metrics.income),
                  icon: Icons.trending_up,
                  accent: AppColors.income,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniCard(
                  title: 'Despesas',
                  value: formatCents(metrics.expenses),
                  icon: Icons.trending_down,
                  accent: AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SavingsCard(value: formatCents(metrics.savings), rate: savingsRate),
          const SizedBox(height: 12),
          _ChartCard(
            title: 'Gastos por categoria',
            child: CategoryDonutChart(
              spending: spending,
              categoriesById: widget.categoriesById,
            ),
          ),
          const SizedBox(height: 12),
          _LatestCard(
            transactions: latest,
            categoriesById: widget.categoriesById,
            accountsById: widget.accountsById,
          ),
          const SizedBox(height: 12),
          _GoalsCard(),
        ],
      ),
    );
  }
}

/// Grid responsivo dos 4 cards de resumo (S4-01/S4-06).
class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.metrics});

  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1024
            ? 4
            : constraints.maxWidth >= 600
                ? 2
                : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: crossAxisCount == 4
              ? 2.4
              : crossAxisCount == 2
                  ? 2.8
                  : 3.2,
          children: [
            SummaryCard(
              title: 'Saldo atual',
              value: formatCents(metrics.balance),
              icon: Icons.account_balance_wallet_outlined,
              accent: AppColors.primary,
              change: metrics.balanceChange,
            ),
            SummaryCard(
              title: 'Receitas',
              value: formatCents(metrics.income),
              icon: Icons.trending_up,
              accent: AppColors.income,
              change: metrics.incomeChange,
            ),
            SummaryCard(
              title: 'Despesas',
              value: formatCents(metrics.expenses),
              icon: Icons.trending_down,
              accent: AppColors.expense,
              change: metrics.expensesChange,
              goodWhenPositive: false,
            ),
            SummaryCard(
              title: 'Economia',
              value: formatCents(metrics.savings),
              icon: Icons.savings_outlined,
              accent: AppColors.warning,
              change: metrics.savingsChange,
            ),
          ],
        );
      },
    );
  }
}

/// Card escuro com título para envolver os gráficos.
class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Card hero mobile: saldo com gradiente roxo, olho de privacidade,
/// variação vs mês anterior e sparkline dos últimos meses.
class _HeroBalanceCard extends StatelessWidget {
  const _HeroBalanceCard({
    required this.metrics,
    required this.evolution,
    required this.hidden,
    required this.onToggle,
  });

  final DashboardMetrics metrics;
  final List<MonthlyTotal> evolution;
  final bool hidden;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final change = metrics.balanceChange;
    final rising = (change ?? 0) >= 0;
    final label = change?.abs().toStringAsFixed(1).replaceAll('.', ',');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Saldo atual',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  hidden ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hidden ? 'R\$ ••••••' : formatCents(metrics.balance),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          if (label != null)
            Row(
              children: [
                Icon(
                  rising ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 2),
                Text(
                  '$label% vs mês anterior',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: CustomPaint(
              size: const Size(double.infinity, 48),
              painter: _SparklinePainter(
                evolution.map((m) => m.amount.toDouble()).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha simples (sparkline) normalizada sobre os valores dos meses.
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final max = values.fold<double>(0, math.max);
    final min = values.reduce(math.min);
    final range = max - min;

    Offset point(int i) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final normalized = range == 0 ? 0.5 : (values[i] - min) / range;
      return Offset(x, size.height * (1 - normalized) - 2 + 2);
    }

    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      point(values.length - 1),
      3,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.values != values;
}

/// Mini card mobile: ícone colorido, título e valor.
class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de economia do mês com anel de porcentagem (mockup img2).
class _SavingsCard extends StatelessWidget {
  const _SavingsCard({required this.value, required this.rate});

  final String value;
  final double? rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CustomPaint(
              painter: _RingPainter(fraction: (rate ?? 0).clamp(0, 100) / 100),
              child: Center(
                child: Text(
                  rate == null
                      ? '–'
                      : '${rate!.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.income,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Economia do mês',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Anel de progresso verde para a taxa de economia.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction});

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final background = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, background);

    final foreground = Paint()
      ..color = AppColors.income
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}

/// Card das 5 transações mais recentes (S4-04).
class _LatestCard extends StatelessWidget {
  const _LatestCard({
    required this.transactions,
    required this.categoriesById,
    required this.accountsById,
  });

  final List<TransactionEntity> transactions;
  final Map<int, CategoryEntity> categoriesById;
  final Map<int, AccountEntity> accountsById;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Últimas transações',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhuma transação registrada',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          for (final transaction in transactions)
            _LatestTile(
              transaction: transaction,
              category: categoriesById[transaction.categoryId],
              account: accountsById[transaction.accountId],
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Linha compacta de transação recente: ícone, descrição, data e valor.
class _LatestTile extends StatelessWidget {
  const _LatestTile({
    required this.transaction,
    required this.category,
    required this.account,
  });

  final TransactionEntity transaction;
  final CategoryEntity? category;
  final AccountEntity? account;

  @override
  Widget build(BuildContext context) {
    final color = category != null
        ? colorFromHex(category!.color)
        : AppColors.textDisabled;
    final sign = transaction.isIncome ? '+' : '-';
    return ListTile(
      dense: true,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionFormScreen(initial: transaction),
          ),
        );
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          category != null ? iconFromName(category!.icon) : Icons.label_outline,
          size: 16,
          color: Colors.white,
        ),
      ),
      title: Text(
        transaction.description ?? category?.name ?? 'Sem categoria',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        dayLabel(transaction.date),
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        '$sign ${formatCents(transaction.amount)}',
        style: TextStyle(
          color: transaction.isIncome ? AppColors.income : AppColors.expense,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Card de metas com barras de progresso roxas (mockup img1).
class _GoalsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metas',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          goals.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: LinearProgressIndicator(minHeight: 4),
            ),
            error: (error, _) => Text(
              'Erro ao carregar: $error',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            data: (goalList) {
              if (goalList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Nenhuma meta ainda. Crie sua primeira meta de economia.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: [
                  for (final goal in goalList.take(3))
                    _GoalProgressTile(goal: goal),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MetasScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                foregroundColor: AppColors.primaryLight,
              ),
              child: const Text('Ver todas as metas'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha de progresso de uma meta dentro do card do dashboard.
class _GoalProgressTile extends ConsumerWidget {
  const _GoalProgressTile({required this.goal});

  final GoalEntity goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributions = ref.watch(goalContributionsProvider(goal.id!));

    return contributions.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(minHeight: 4),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (contributionList) {
        final contributed = totalContributed(contributionList);
        final percent = progressPercent(
          targetAmount: goal.targetAmount,
          contributed: contributed,
        );
        final color = colorFromHex(goal.color);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(iconFromName(goal.icon), size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      goal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${percent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: (percent > 100 ? 100 : percent) / 100,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${formatCents(contributed)} de '
                '${formatCents(goal.targetAmount)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Faixa inferior de insights automáticos em cards claros (mockup img1).
class _InsightsStrip extends StatelessWidget {
  const _InsightsStrip({required this.items, required this.categoriesById});

  final List<TransactionEntity> items;
  final Map<int, CategoryEntity> categoriesById;

  @override
  Widget build(BuildContext context) {
    final insights = buildInsights(
      items,
      categoryNames: {for (final c in categoriesById.values) c.id: c.name},
    );
    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final insight in insights)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _InsightCard(insight: insight),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Card claro de um insight com ícone colorido por tipo.
class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (insight.kind) {
      InsightKind.warning => (Icons.warning_amber_rounded, AppColors.warning),
      InsightKind.info => (Icons.lightbulb_outline, AppColors.info),
      InsightKind.positive => (Icons.emoji_events_outlined, AppColors.income),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight.message,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
