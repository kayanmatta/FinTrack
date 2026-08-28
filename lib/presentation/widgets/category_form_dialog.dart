import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../domain/entities/category_entity.dart';

/// Resultado do formulário de criação/edição de categoria.
class CategoryFormResult {
  const CategoryFormResult({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  final String name;
  final String icon;
  final String color;
  final String type;
}

/// Abre o diálogo de criação/edição de categoria.
///
/// Retorna `null` se o usuário cancelar.
Future<CategoryFormResult?> showCategoryFormDialog(
  BuildContext context, {
  CategoryEntity? initial,
}) {
  return showDialog<CategoryFormResult>(
    context: context,
    builder: (_) => _CategoryFormDialog(initial: initial),
  );
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.initial});

  final CategoryEntity? initial;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late final TextEditingController _nameController;
  late String _icon;
  late Color _color;
  late String _type;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _icon = initial?.icon ?? 'shopping_cart';
    _color = colorFromHex(initial?.color);
    _type = initial?.type ?? 'despesa';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Informe um nome para a categoria.');
      return;
    }
    Navigator.of(context).pop(
      CategoryFormResult(
        name: name,
        icon: _icon,
        color: colorToHex(_color),
        type: _type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nova categoria' : 'Editar categoria'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                errorText: _nameError,
              ),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ChoiceChip(
                  selected: _type == 'despesa',
                  onSelected: (_) => setState(() => _type = 'despesa'),
                  label: const Text('Despesa'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  selected: _type == 'receita',
                  onSelected: (_) => setState(() => _type = 'receita'),
                  label: const Text('Receita'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Ícone'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in categoryIcons.entries)
                  _IconOption(
                    icon: entry.value,
                    selected: _icon == entry.key,
                    color: _color,
                    onTap: () => setState(() => _icon = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Cor'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in presetColors)
                  _ColorOption(
                    color: color,
                    selected: colorToHex(color) == colorToHex(_color),
                    onTap: () => setState(() => _color = color),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}

class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: selected ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            width: 3,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 18, color: AppColors.textPrimary)
            : null,
      ),
    );
  }
}
