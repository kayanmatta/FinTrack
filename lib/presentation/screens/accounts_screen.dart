import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/account_meta.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../domain/entities/account_entity.dart';
import '../providers/account_provider.dart';
import '../widgets/account_form_dialog.dart';

/// Gerenciamento de contas financeiras (criar, editar, excluir).
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Contas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        child: const Icon(Icons.add),
      ),
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma conta cadastrada.\nToque em + para criar.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final account in list)
                _AccountTile(
                  account: account,
                  onEdit: () => _edit(context, ref, account),
                  onDelete: () => _delete(context, ref, account),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await showAccountFormDialog(context);
    if (result == null) return;
    await ref.read(accountRepositoryProvider).create(
          name: result.name,
          type: result.type,
          initialBalance: result.initialBalance,
          color: result.color,
        );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    AccountEntity account,
  ) async {
    final result = await showAccountFormDialog(context, initial: account);
    if (result == null) return;
    await ref.read(accountRepositoryProvider).update(
          account.copyWith(
            name: result.name,
            type: result.type,
            initialBalance: result.initialBalance,
            color: result.color,
          ),
        );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AccountEntity account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: Text(
          'Excluir "${account.name}"? '
          'Transações vinculadas ficarão sem conta.',
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
      await ref.read(accountRepositoryProvider).delete(account.id);
    }
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  final AccountEntity account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(account.color);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(accountTypeIcon(account.type),
              color: AppColors.textPrimary),
        ),
        title: Text(account.name),
        subtitle: Text(
          '${accountTypeLabel(account.type)} · '
          'saldo inicial ${formatCents(account.initialBalance)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }
}
