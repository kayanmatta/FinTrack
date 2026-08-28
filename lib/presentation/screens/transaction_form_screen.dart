import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/account_meta.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';

/// Formulário de criação e edição de transações (S3-01, S3-04, S3-05).
///
/// Tipo (receita/despesa), valor, categoria em grade de ícones,
/// data, descrição e conta. Com [initial], edita e permite excluir.
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.initial});

  /// Transação a editar; `null` para criar uma nova.
  final TransactionEntity? initial;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  late String _type;
  late int? _categoryId;
  late int? _accountId;
  late DateTime _date;
  String? _amountError;

  bool get _editing => widget.initial != null;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

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
    _date = initial != null
        ? DateTime(initial.date.year, initial.date.month, initial.date.day)
        : _today();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String? get _description {
    final text = _descriptionController.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save(WidgetRef ref) async {
    final amount = parseCents(_amountController.text);
    setState(() {
      _amountError = amount <= 0 ? 'Informe um valor maior que zero.' : null;
    });
    if (amount <= 0) return;

    final repository = ref.read(transactionRepositoryProvider);
    final initial = widget.initial;
    if (initial == null) {
      await repository.create(
        type: _type,
        amount: amount,
        categoryId: _categoryId,
        accountId: _accountId,
        date: _date,
        description: _description,
      );
    } else {
      await repository.update(
        initial.copyWith(
          type: _type,
          amount: amount,
          categoryId: () => _categoryId,
          accountId: () => _accountId,
          date: _date,
          description: () => _description,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete(WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir transação'),
        content: const Text(
          'Tem certeza que deseja excluir esta transação? '
          'Esta ação não pode ser desfeita.',
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

    await ref.read(transactionRepositoryProvider).delete(widget.initial!.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final categories = ref.watch(categoriesProvider);
        final accounts = ref.watch(accountsProvider);
        return Scaffold(
          appBar: AppBar(
            title: Text(_editing ? 'Editar transação' : 'Nova transação'),
            actions: [
              if (_editing)
                IconButton(
                  tooltip: 'Excluir',
                  onPressed: () => _delete(ref),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
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
                    labelText: 'Valor',
                    prefixText: 'R\$ ',
                    hintText: '0,00',
                    errorText: _amountError,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) {
                    if (_amountError != null) {
                      setState(() => _amountError = null);
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text('Categoria'),
                const SizedBox(height: 8),
                categories.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text('Erro ao carregar: $error'),
                  data: (items) {
                    final filtered = [
                      for (final category in items)
                        if (category.type == _type) category,
                    ];
                    if (filtered.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Nenhuma categoria deste tipo. '
                          'Cadastre em Ajustes → Categorias.',
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final category in filtered)
                          _CategoryOption(
                            category: category,
                            selected: category.id == _categoryId,
                            onTap: () =>
                                setState(() => _categoryId = category.id),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('dd/MM/yyyy').format(_date)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                  ),
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
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _save(ref),
                  icon: const Icon(Icons.check),
                  label: const Text('Salvar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Opção de categoria na grade (ícone colorido + nome).
class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final CategoryEntity category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(category.color);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryLight : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(
                iconFromName(category.icon),
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
