import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/account_meta.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../domain/entities/account_entity.dart';

/// Resultado do formulário de criação/edição de conta.
class AccountFormResult {
  const AccountFormResult({
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.color,
  });

  final String name;
  final String type;
  final int initialBalance;
  final String color;
}

/// Abre o diálogo de criação/edição de conta financeira.
///
/// Retorna `null` se o usuário cancelar.
Future<AccountFormResult?> showAccountFormDialog(
  BuildContext context, {
  AccountEntity? initial,
}) {
  return showDialog<AccountFormResult>(
    context: context,
    builder: (_) => _AccountFormDialog(initial: initial),
  );
}

class _AccountFormDialog extends StatefulWidget {
  const _AccountFormDialog({this.initial});

  final AccountEntity? initial;

  @override
  State<_AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends State<_AccountFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late String _type;
  late Color _color;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _balanceController = TextEditingController(
      text: initial == null
          ? ''
          : (initial.initialBalance / 100)
              .toStringAsFixed(2)
              .replaceFirst('.', ','),
    );
    _type = initial?.type ?? 'carteira';
    _color = colorFromHex(initial?.color);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Informe um nome para a conta.');
      return;
    }
    Navigator.of(context).pop(
      AccountFormResult(
        name: name,
        type: _type,
        initialBalance: parseCents(_balanceController.text),
        color: colorToHex(_color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nova conta' : 'Editar conta'),
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
            const Text('Tipo'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in accountTypeLabels.entries)
                  ChoiceChip(
                    selected: _type == entry.key,
                    onSelected: (_) => setState(() => _type = entry.key),
                    label: Text(entry.value),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Saldo inicial',
                prefixText: 'R\$ ',
                hintText: '0,00',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
