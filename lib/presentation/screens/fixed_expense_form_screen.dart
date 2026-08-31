import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/account_meta.dart';
import '../../core/utils/currency_utils.dart';
import '../../domain/entities/fixed_expense_entity.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/fixed_expense_provider.dart';

/// Formulário de lançamento fixo (S9): tipo, valor, dia de vencimento,
/// categoria, conta e descrição.
class FixedExpenseFormScreen extends ConsumerStatefulWidget {
  const FixedExpenseFormScreen({super.key, this.initial});

  /// Lançamento em edição (nulo para criação).
  final FixedExpenseEntity? initial;

  @override
  ConsumerState<FixedExpenseFormScreen> createState() =>
      _FixedExpenseFormScreenState();
}

class _FixedExpenseFormScreenState
    extends ConsumerState<FixedExpenseFormScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  late String _type;
  late int? _categoryId;
  late int? _accountId;
  late int _day;
  String? _amountError;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _amountController = TextEditingController(
      text: initial == null
          ? ''
          : (initial.amount / 100)
              .toStringAsFixed(2)
              .replaceFirst('.', ','),
    );
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _type = initial?.type ?? 'despesa';
    _categoryId = initial?.categoryId;
    _accountId = initial?.accountId;
    _day = initial?.day ?? 5;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? get _description {
    final text = _descriptionController.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    final amount = parseCents(_amountController.text);
    setState(() {
      _amountError = amount <= 0 ? 'Informe um valor maior que zero.' : null;
    });
    if (amount <= 0) return;

    final repository = ref.read(fixedExpenseRepositoryProvider);
    final initial = widget.initial;
    if (initial == null) {
      await repository.create(
        type: _type,
        amount: amount,
        day: _day,
        categoryId: _categoryId,
        accountId: _accountId,
        description: _description,
      );
    } else {
      await repository.update(
        initial.copyWith(
          type: _type,
          amount: amount,
          day: _day,
          categoryId: _categoryId,
          accountId: _accountId,
          description: _description,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
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
    if (confirmed != true) return;

    await ref.read(fixedExpenseRepositoryProvider).delete(widget.initial!.id);
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Editar lançamento fixo' : 'Novo lançamento fixo'),
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Excluir',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'despesa',
                label: Text('Despesa'),
                icon: Icon(Icons.arrow_downward),
              ),
              ButtonSegment(
                value: 'receita',
                label: Text('Receita'),
                icon: Icon(Icons.arrow_upward),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) {
              setState(() {
                _type = selection.first;
                _categoryId = null;
              });
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Valor mensal',
              prefixText: 'R\$ ',
              hintText: '0,00',
              errorText: _amountError,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              if (_amountError != null) setState(() => _amountError = null);
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            initialValue: _day,
            decoration: const InputDecoration(labelText: 'Dia de vencimento'),
            items: [
              for (var day = 1; day <= 31; day++)
                DropdownMenuItem(value: day, child: Text('Dia $day')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _day = value);
            },
          ),
          const SizedBox(height: 20),
          categories.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => Text('Erro ao carregar: $error'),
            data: (items) {
              final filtered = [
                for (final category in items)
                  if (category.type == _type) category,
              ];
              if (_categoryId != null &&
                  !filtered.any((category) => category.id == _categoryId)) {
                _categoryId = null;
              }
              return DropdownButtonFormField<int?>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sem categoria'),
                  ),
                  for (final category in filtered)
                    DropdownMenuItem(value: category.id, child: Text(category.name)),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              );
            },
          ),
          const SizedBox(height: 20),
          accounts.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => Text('Erro ao carregar: $error'),
            data: (items) => DropdownButtonFormField<int?>(
              initialValue: _accountId,
              decoration: const InputDecoration(labelText: 'Conta'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Sem conta'),
                ),
                for (final account in items)
                  DropdownMenuItem(
                    value: account.id,
                    child: Text(
                      '${account.name} (${accountTypeLabel(account.type)})',
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _accountId = value),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              hintText: 'Ex.: Aluguel, Internet, Salário...',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
