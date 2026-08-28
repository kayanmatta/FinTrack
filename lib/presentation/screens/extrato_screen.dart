import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';

/// Lista de receitas e despesas agrupadas por dia (S3-03).
///
/// Cabeçalhos: Hoje, Ontem ou a data completa; a busca e os filtros
/// chegam na S3-06.
class ExtratoScreen extends ConsumerWidget {
  const ExtratoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Extrato')),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyState();
          }
          final categoriesById = _byId(categories, (c) => c.id);
          final accountsById = _byId(accounts, (a) => a.id);
          final groups = _groupByDay(items);
          return ListView(
            children: [
              for (final group in groups.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Text(
                    dayLabel(group.key),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                for (final transaction in group.value)
                  _TransactionTile(
                    transaction: transaction,
                    category: categoriesById[transaction.categoryId],
                    account: accountsById[transaction.accountId],
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Map<int, T> _byId<T>(AsyncValue<List<T>> source, int Function(T) id) {
    return source.maybeWhen(
      data: (items) => {for (final item in items) id(item): item},
      orElse: () => <int, T>{},
    );
  }

  Map<DateTime, List<TransactionEntity>> _groupByDay(
    List<TransactionEntity> items,
  ) {
    final groups = <DateTime, List<TransactionEntity>>{};
    for (final transaction in items) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      groups.putIfAbsent(day, () => []).add(transaction);
    }
    return groups;
  }
}

/// Linha de transação: ícone da categoria, descrição e valor.
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
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
    final amountColor =
        transaction.isIncome ? AppColors.income : AppColors.expense;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(
          category != null ? iconFromName(category!.icon) : Icons.label_outline,
          size: 20,
          color: color,
        ),
      ),
      title: Text(
        transaction.description ?? category?.name ?? 'Sem categoria',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        account == null
            ? (category?.name ?? 'Sem categoria')
            : '${category?.name ?? 'Sem categoria'} · ${account!.name}',
      ),
      trailing: Text(
        '$sign ${formatCents(transaction.amount)}',
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Estado vazio: nenhuma transação registrada ainda.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma transação registrada',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Toque em "Nova transação" para registrar sua '
              'primeira receita ou despesa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
