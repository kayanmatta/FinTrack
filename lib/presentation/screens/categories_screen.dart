import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/category_provider.dart';
import '../widgets/category_form_dialog.dart';

/// Gerenciamento de categorias (criar, editar, excluir).
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        child: const Icon(Icons.add),
      ),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma categoria cadastrada.\nToque em + para criar.',
                textAlign: TextAlign.center,
              ),
            );
          }
          final despesas =
              list.where((c) => c.type == 'despesa').toList();
          final receitas =
              list.where((c) => c.type == 'receita').toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (despesas.isNotEmpty) ...[
                const _SectionHeader('Despesas'),
                for (final category in despesas)
                  _CategoryTile(
                    category: category,
                    onEdit: () => _edit(context, ref, category),
                    onDelete: () => _delete(context, ref, category),
                  ),
              ],
              if (receitas.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _SectionHeader('Receitas'),
                for (final category in receitas)
                  _CategoryTile(
                    category: category,
                    onEdit: () => _edit(context, ref, category),
                    onDelete: () => _delete(context, ref, category),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await showCategoryFormDialog(context);
    if (result == null) return;
    await ref.read(categoryRepositoryProvider).create(
          name: result.name,
          icon: result.icon,
          color: result.color,
          type: result.type,
        );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity category,
  ) async {
    final result = await showCategoryFormDialog(context, initial: category);
    if (result == null) return;
    await ref.read(categoryRepositoryProvider).update(
          category.copyWith(
            name: result.name,
            icon: result.icon,
            color: result.color,
            type: result.type,
          ),
        );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text(
          'Excluir "${category.name}"? '
          'Transações vinculadas ficarão sem categoria.',
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
      await ref.read(categoryRepositoryProvider).delete(category.id);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(category.color);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(iconFromName(category.icon), color: AppColors.textPrimary),
        ),
        title: Text(category.name),
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
