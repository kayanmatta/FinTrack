import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../domain/entities/fixed_expense_entity.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/fixed_expense_provider.dart';
import 'fixed_expense_form_screen.dart';

/// Aba de lançamentos fixos (S9): ficam pendentes a cada mês e só contam
/// no saldo/extrato quando o pagamento é confirmado.
class FixosScreen extends ConsumerWidget {
  const FixosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(fixedExpensesProvider);
    final payments = ref.watch(fixedPaymentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Novo lançamento fixo',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FixedExpenseFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: expenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhum lançamento fixo ainda.\n'
                  'Toque em + para cadastrar aluguel, internet, salário...\n'
                  'Eles ficam pendentes todo mês e só entram no saldo '
                  'quando você marca como pagos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          return payments.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Erro ao carregar: $error')),
            data: (paymentList) => _Body(
              expenses: list,
              payments: paymentList,
            ),
          );
        },
      ),
    );
  }
}

/// Resumo do mês + lista de lançamentos com status pendente/pago.
class _Body extends ConsumerWidget {
  const _Body({required this.expenses, required this.payments});

  final List<FixedExpenseEntity> expenses;
  final List<FixedExpensePaymentEntity> payments;

  String get _monthKey {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthKey = _monthKey;
    final paidByFixed = {
      for (final payment in payments)
        if (payment.month == monthKey) payment.fixedId: payment,
    };

    var total = 0;
    var paid = 0;
    for (final expense in expenses) {
      total += expense.amount;
      if (paidByFixed.containsKey(expense.id)) paid += expense.amount;
    }
    final pending = total - paid;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _SummaryCell(
                label: 'Total do mês',
                value: formatCents(total),
                color: AppColors.textPrimary,
              ),
              _SummaryCell(
                label: 'Pago',
                value: formatCents(paid),
                color: AppColors.income,
              ),
              _SummaryCell(
                label: 'Pendente',
                value: formatCents(pending),
                color: pending > 0 ? AppColors.warning : AppColors.income,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final expense in expenses) ...[
          _FixedCard(
            expense: expense,
            payment: paidByFixed[expense.id],
            monthKey: monthKey,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Uma coluna do resumo mensal (total, pago, pendente).
class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ $value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de um lançamento fixo com status do mês e ações pagar/desfazer.
class _FixedCard extends ConsumerWidget {
  const _FixedCard({
    required this.expense,
    required this.payment,
    required this.monthKey,
  });

  final FixedExpenseEntity expense;
  final FixedExpensePaymentEntity? payment;
  final String monthKey;

  bool get _paid => payment != null;

  Future<void> _toggle(WidgetRef ref) async {
    final repository = ref.read(fixedExpenseRepositoryProvider);
    if (_paid) {
      await repository.unpay(payment!.id);
    } else {
      await repository.pay(expense.id, month: monthKey);
    }
  }

  Future<void> _edit(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FixedExpenseFormScreen(initial: expense),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir lançamento fixo?'),
        content: const Text(
          'Ele deixa de aparecer nos próximos meses. '
          'Os pagamentos já confirmados permanecem no extrato.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(fixedExpenseRepositoryProvider).delete(expense.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final matchingCategories = [
      for (final c in categories)
        if (c.id == expense.categoryId) c,
    ];
    final category = matchingCategories.isEmpty ? null : matchingCategories.first;
    final matchingAccounts = [
      for (final a in accounts)
        if (a.id == expense.accountId) a,
    ];
    final account = matchingAccounts.isEmpty ? null : matchingAccounts.first;
    final color = colorFromHex(category?.color);
    final sign = expense.isIncome ? '+' : '-';

    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _edit(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(
                  category != null ? iconFromName(category.icon) : Icons.repeat,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description ??
                          category?.name ??
                          'Sem categoria',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vence dia ${expense.day}'
                      '${account != null ? ' · ${account.name}' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
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
                    '$sign ${formatCents(expense.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: expense.isIncome
                          ? AppColors.income
                          : AppColors.expense,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_paid)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Pago',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.income,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Pendente',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              _paid
                  ? IconButton(
                      tooltip: 'Desfazer pagamento',
                      icon: const Icon(Icons.undo_outlined),
                      onPressed: () => _toggle(ref),
                    )
                  : FilledButton(
                      onPressed: () => _toggle(ref),
                      child: const Text('Pagar'),
                    ),
              IconButton(
                tooltip: 'Excluir',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
