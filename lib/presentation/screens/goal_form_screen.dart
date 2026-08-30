import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../providers/goal_provider.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');

/// Cores disponíveis para a meta.
const _goalColors = [
  '#9F67FF',
  '#10B981',
  '#3B82F6',
  '#F59E0B',
  '#EF4444',
  '#EC4899',
];

/// Formulário de criação de meta: nome, valor alvo, prazo, ícone e cor
/// (S7-01).
class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key});

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime? _deadline;
  String _icon = categoryIcons.keys.first;
  String _color = _goalColors.first;
  String? _nameError;
  String? _targetError;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime(now.year + 1),
      firstDate: now,
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final target = parseCents(_targetController.text);
    setState(() {
      _nameError = name.isEmpty ? 'Informe um nome para a meta.' : null;
      _targetError =
          target <= 0 ? 'Informe um valor maior que zero.' : null;
    });
    if (name.isEmpty || target <= 0) return;

    setState(() => _saving = true);
    await ref.read(goalRepositoryProvider).create(
          name: name,
          targetAmount: target,
          deadline: _deadline,
          icon: _icon,
          color: _color,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova meta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome da meta',
              hintText: 'Ex.: Reserva de emergência',
              errorText: _nameError,
            ),
            onChanged: (_) => setState(() => _nameError = null),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _targetController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: 'Valor alvo',
              prefixText: 'R\$ ',
              errorText: _targetError,
            ),
            onChanged: (_) => setState(() => _targetError = null),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _deadline == null
                      ? 'Sem prazo definido'
                      : 'Prazo: ${_dateFormat.format(_deadline!)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              if (_deadline != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Remover prazo',
                  onPressed: () => setState(() => _deadline = null),
                ),
              TextButton.icon(
                onPressed: _pickDeadline,
                icon: const Icon(Icons.event_outlined),
                label: const Text('Definir prazo'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ícone',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in categoryIcons.entries)
                GestureDetector(
                  onTap: () => setState(() => _icon = entry.key),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: _icon == entry.key
                        ? AppColors.primary
                        : AppColors.surface,
                    child: Icon(
                      entry.value,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Cor',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final hex in _goalColors)
                GestureDetector(
                  onTap: () => setState(() => _color = hex),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorFromHex(hex),
                      shape: BoxShape.circle,
                      border: _color == hex
                          ? Border.all(
                              color: AppColors.textPrimary,
                              width: 2,
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
            label: const Text('Salvar meta'),
          ),
        ],
      ),
    );
  }
}
