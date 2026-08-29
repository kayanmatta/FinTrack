import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/finance_metrics.dart';
import '../../core/utils/financial_analytics.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/summary_card.dart';

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

/// Tela de análises: cards analíticos, ranking de gastos, comparativo
/// mensal, resumo do mês e insights automáticos (Sprint 5).
class AnalisesScreen extends ConsumerStatefulWidget {
  const AnalisesScreen({super.key});

  @override
  ConsumerState<AnalisesScreen> createState() => _AnalisesScreenState();
}

class _AnalisesScreenState extends ConsumerState<AnalisesScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  int? _categoryFilter;

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Análises')),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: (items) {
          final allCategories = categories.valueOrNull ?? <CategoryEntity>[];
          final filtered = _categoryFilter == null
              ? items
              : items
                  .where((t) => t.categoryId == _categoryFilter)
                  .toList();
          return _buildBody(filtered, allCategories);
        },
      ),
    );
  }

  Widget _buildBody(
    List<TransactionEntity> items,
    List<CategoryEntity> allCategories,
  ) {
    final categoriesById = {for (final c in allCategories) c.id: c};
    final categoryNames = {for (final c in allCategories) c.id: c.name};

    final metrics = _metricsFor(items, _month);
    final ranking = topExpenses(items, reference: _month);
    final evolution = expenseEvolution(items, reference: _month);
    // Média diária: dias decorridos no mês atual, mês cheio no passado.
    final summaryReference = _isCurrentMonth
        ? DateTime.now()
        : DateTime(_month.year, _month.month + 1, 0);
    final summary = monthSummary(items, reference: summaryReference);
    final insights = buildInsights(
      items,
      categoryNames: categoryNames,
      reference: _month,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MonthHeader(
          month: _month,
          isCurrentMonth: _isCurrentMonth,
          categoryFilter: _categoryFilter,
          categories: allCategories,
          onChangedMonth: _changeMonth,
          onChangedCategory: (id) => setState(() => _categoryFilter = id),
        ),
        const SizedBox(height: 12),
        _AnalyticsCards(metrics: metrics),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final rankingCard = _SectionCard(
              title: 'Maiores gastos do mês',
              child: _RankingList(
                ranking: ranking,
                categoriesById: categoriesById,
              ),
            );
            final barCard = _SectionCard(
              title: 'Comparativo mensal',
              child: SizedBox(
                height: 220,
                child: MonthlyBarChart(evolution: evolution),
              ),
            );
            final summaryCard = _SectionCard(
              title: 'Resumo do mês',
              child: _SummaryRows(summary: summary),
            );
            final insightsCard = _SectionCard(
              title: 'Insights para você',
              child: _InsightList(insights: insights),
            );
            if (isDesktop) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: rankingCard),
                      const SizedBox(width: 12),
                      Expanded(child: barCard),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: summaryCard),
                      const SizedBox(width: 12),
                      Expanded(child: insightsCard),
                    ],
                  ),
                ],
              );
            }
            return Column(
              children: [
                rankingCard,
                const SizedBox(height: 12),
                barCard,
                const SizedBox(height: 12),
                summaryCard,
                const SizedBox(height: 12),
                insightsCard,
              ],
            );
          },
        ),
      ],
    );
  }

  /// Métricas dos cards para o mês selecionado (S5-01), com o saldo
  /// acumulado até o final daquele mês.
  DashboardMetrics _metricsFor(
    List<TransactionEntity> items,
    DateTime month,
  ) {
    final previous = DateTime(month.year, month.month - 1);
    final income = incomeOfMonth(items, month);
    final expenses = expensesOfMonth(items, month);
    final previousIncome = incomeOfMonth(items, previous);
    final previousExpenses = expensesOfMonth(items, previous);
    final balance = balanceUpTo(items, month);
    final previousBalance = balanceUpTo(items, previous);
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
}

/// Seletor de mês + filtro de categoria (S5-07).
class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.isCurrentMonth,
    required this.categoryFilter,
    required this.categories,
    required this.onChangedMonth,
    required this.onChangedCategory,
  });

  final DateTime month;
  final bool isCurrentMonth;
  final int? categoryFilter;
  final List<CategoryEntity> categories;
  final ValueChanged<int> onChangedMonth;
  final ValueChanged<int?> onChangedCategory;

  @override
  Widget build(BuildContext context) {
    final expensesCategories = [
      for (final category in categories)
        if (category.type == 'despesa') category,
    ];
    final selectedName = expensesCategories
        .where((category) => category.id == categoryFilter)
        .map((category) => category.name)
        .toList();
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Mês anterior',
          onPressed: () => onChangedMonth(-1),
        ),
        Text(
          '${_monthNames[month.month - 1]} de ${month.year}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Próximo mês',
          onPressed: isCurrentMonth ? null : () => onChangedMonth(1),
        ),
        const Spacer(),
        PopupMenuButton<int?>(
          initialValue: categoryFilter,
          onSelected: onChangedCategory,
          child: InputChip(
            label: Text(
              selectedName.isEmpty
                  ? 'Todas categorias'
                  : selectedName.first,
            ),
            avatar: const Icon(Icons.filter_list, size: 16),
            onPressed: null,
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: null,
              child: Text('Todas categorias'),
            ),
            for (final category in expensesCategories)
              PopupMenuItem(value: category.id, child: Text(category.name)),
          ],
        ),
      ],
    );
  }
}

/// Grid responsivo dos 4 cards analíticos (S5-01/S5-06).
class _AnalyticsCards extends StatelessWidget {
  const _AnalyticsCards({required this.metrics});

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
              title: 'Saldo',
              value: formatCents(metrics.balance),
              icon: Icons.account_balance_wallet_outlined,
              accent: AppColors.info,
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

/// Card container com título, igual ao do dashboard.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Ranking das maiores despesas do mês (S5-02).
class _RankingList extends StatelessWidget {
  const _RankingList({
    required this.ranking,
    required this.categoriesById,
  });

  final List<RankedExpense> ranking;
  final Map<int?, CategoryEntity> categoriesById;

  @override
  Widget build(BuildContext context) {
    if (ranking.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Sem despesas neste mês',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final item in ranking) ...[
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorFromHex(
                  categoriesById[item.categoryId]?.color,
                ).withValues(alpha: 0.2),
                child: Icon(
                  iconFromName(categoriesById[item.categoryId]?.icon),
                  size: 16,
                  color: colorFromHex(categoriesById[item.categoryId]?.color),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description ?? 'Sem descrição',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      categoriesById[item.categoryId]?.name ??
                          'Sem categoria',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCents(item.amount),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${item.percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Linhas do resumo do mês (S5-04).
class _SummaryRows extends StatelessWidget {
  const _SummaryRows({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryRow(
          label: 'Total de transações',
          value: '${summary.transactionCount}',
        ),
        _SummaryRow(
          label: 'Maior despesa',
          value: summary.largestExpense == null
              ? '—'
              : formatCents(summary.largestExpense!),
        ),
        _SummaryRow(
          label: 'Menor despesa',
          value: summary.smallestExpense == null
              ? '—'
              : formatCents(summary.smallestExpense!),
        ),
        _SummaryRow(
          label: 'Média diária de gastos',
          value: formatCents(summary.dailyAverageExpenses.round()),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cards de insights automáticos (S5-05).
class _InsightList extends StatelessWidget {
  const _InsightList({required this.insights});

  final List<Insight> insights;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Sem insights para este mês',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final insight in insights) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconFor(insight.kind), size: 18, color: _colorFor(insight.kind)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  insight.message,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  IconData _iconFor(InsightKind kind) => switch (kind) {
    InsightKind.warning => Icons.warning_amber_rounded,
    InsightKind.info => Icons.insights,
    InsightKind.positive => Icons.emoji_events_outlined,
  };

  Color _colorFor(InsightKind kind) => switch (kind) {
    InsightKind.warning => AppColors.warning,
    InsightKind.info => AppColors.info,
    InsightKind.positive => AppColors.income,
  };
}
