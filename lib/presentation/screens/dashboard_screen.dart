import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/finance_metrics.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/expense_line_chart.dart';
import '../widgets/summary_card.dart';
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
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: (items) => _buildSummary(
          items,
          categoriesById: {
            for (final c in categories.valueOrNull ?? <CategoryEntity>[])
              c.id: c,
          },
          accountsById: {
            for (final a in accounts.valueOrNull ?? <AccountEntity>[])
              a.id: a,
          },
        ),
      ),
    );
  }

  Widget _buildSummary(
    List<TransactionEntity> items, {
    required Map<int, CategoryEntity> categoriesById,
    required Map<int, AccountEntity> accountsById,
  }) {
    final now = DateTime.now();
    final metrics = dashboardMetrics(items, reference: now);
    final spending = spendingByCategory(items, reference: now);
    final evolution = expenseEvolution(items, reference: now);
    final latest = latestTransactions(items);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Resumo de ${_monthNames[now.month - 1]}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _SummaryCards(metrics: metrics),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final donut = _ChartCard(
              title: 'Gastos por categoria',
              child: CategoryDonutChart(
                spending: spending,
                categoriesById: categoriesById,
              ),
            );
            final line = _ChartCard(
              title: 'Evolução de despesas',
              child: SizedBox(
                height: 220,
                child: ExpenseLineChart(evolution: evolution),
              ),
            );
            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: donut),
                  const SizedBox(width: 12),
                  Expanded(child: line),
                ],
              );
            }
            return Column(
              children: [donut, const SizedBox(height: 12), line],
            );
          },
        ),
        const SizedBox(height: 16),
        _LatestTransactions(
          transactions: latest,
          categoriesById: categoriesById,
          accountsById: accountsById,
        ),
      ],
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
          childAspectRatio: crossAxisCount >= 2 ? 3 : 3.4,
          children: [
            SummaryCard(
              title: 'Saldo atual',
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

/// Card container com título para envolver os gráficos.
class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Lista das 5 transações mais recentes no dashboard (S4-04).
class _LatestTransactions extends StatelessWidget {
  const _LatestTransactions({
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
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Últimas transações',
              style: TextStyle(fontWeight: FontWeight.w600),
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
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(
          category != null ? iconFromName(category!.icon) : Icons.label_outline,
          size: 16,
          color: color,
        ),
      ),
      title: Text(
        transaction.description ?? category?.name ?? 'Sem categoria',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        dayLabel(transaction.date),
        style: const TextStyle(fontSize: 12),
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
