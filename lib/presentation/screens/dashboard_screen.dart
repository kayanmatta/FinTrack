import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/finance_metrics.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_provider.dart';
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

/// Tela inicial com resumo financeiro (S4).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: _buildSummary,
      ),
    );
  }

  Widget _buildSummary(List<TransactionEntity> items) {
    final now = DateTime.now();
    final metrics = dashboardMetrics(items, reference: now);
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
        LayoutBuilder(
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
        ),
      ],
    );
  }
}
