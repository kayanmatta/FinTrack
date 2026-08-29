import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/budget_metrics.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/financial_analytics.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';

/// Tela de orçamento: definição de renda e alocação por categoria,
/// barras de progresso, alertas e saldo restante (Sprint 6).
class OrcamentoScreen extends ConsumerStatefulWidget {
  const OrcamentoScreen({super.key});

  @override
  ConsumerState<OrcamentoScreen> createState() => _OrcamentoScreenState();
}

class _OrcamentoScreenState extends ConsumerState<OrcamentoScreen> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final key = monthKey(month);
    final previousKey = monthKey(DateTime(now.year, now.month - 1));

    final budgets = ref.watch(budgetsProvider(key));
    final previousBudgets = ref.watch(budgetsProvider(previousKey));
    final income = ref.watch(budgetIncomeProvider(key));
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamento'),
        actions: [
          if (!_editing && income.hasValue && income.value != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Ajustar orçamento',
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: budgets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: (budgetList) => income.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Erro ao carregar: $error'),
          ),
          data: (incomeValue) => categories.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Erro ao carregar: $error'),
            ),
            data: (categoryList) => transactions.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text('Erro ao carregar: $error'),
              ),
              data: (transactionList) => _buildBody(
                budgetList: budgetList,
                previousBudgets: previousBudgets.valueOrNull ?? const [],
                incomeValue: incomeValue,
                categoryList: categoryList,
                transactionList: transactionList,
                month: month,
                key: key,
                previousKey: previousKey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required List<BudgetEntity> budgetList,
    required List<BudgetEntity> previousBudgets,
    required int? incomeValue,
    required List<CategoryEntity> categoryList,
    required List<TransactionEntity> transactionList,
    required DateTime month,
    required String key,
    required String previousKey,
  }) {
    final expenseCategories = [
      for (final category in categoryList)
        if (category.type == 'despesa') category,
    ];

    // Sem orçamento definido (ou ajustando): formulário de definição.
    if (incomeValue == null || _editing) {
      return _BudgetForm(
        categories: expenseCategories,
        initialIncome: incomeValue,
        initialAllocations: {
          for (final budget in budgetList)
            budget.categoryId: budget.limitAmount,
        },
        canCopyPrevious: previousBudgets.isNotEmpty,
        onCancel: incomeValue == null
            ? null
            : () => setState(() => _editing = false),
        onCopyPrevious: () async {
          await ref
              .read(budgetRepositoryProvider)
              .copyMonth(previousKey, key);
          setState(() => _editing = false);
        },
        onSave: (income, allocations) async {
          await ref.read(budgetRepositoryProvider).save(
                month: key,
                income: income,
                allocations: allocations,
              );
          setState(() => _editing = false);
        },
      );
    }

    final statuses = buildBudgetStatuses(budgetList, transactionList, month);
    final totals = budgetTotals(statuses);
    final alerts = budgetAlerts(statuses);
    final categoriesById = {for (final c in categoryList) c.id: c};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TotalsCard(totals: totals),
        const SizedBox(height: 16),
        if (alerts.isNotEmpty) ...[
          _AlertBanners(alerts: alerts, categoriesById: categoriesById),
          const SizedBox(height: 16),
        ],
        _ProgressList(
          statuses: statuses,
          categoriesById: categoriesById,
        ),
      ],
    );
  }
}

/// Card geral: total alocado, gasto e disponível (S6-05).
class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.totals});

  final BudgetTotals totals;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _TotalColumn(
              label: 'Alocado',
              value: formatCents(totals.allocated),
              color: AppColors.textPrimary,
            ),
            _TotalColumn(
              label: 'Gasto',
              value: formatCents(totals.spent),
              color: AppColors.expense,
            ),
            _TotalColumn(
              label: 'Disponível',
              value: formatCents(totals.available),
              color: totals.available < 0
                  ? AppColors.expense
                  : AppColors.income,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalColumn extends StatelessWidget {
  const _TotalColumn({
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
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banners de alerta quando o gasto atinge 80% ou 100% do limite (S6-03).
class _AlertBanners extends StatelessWidget {
  const _AlertBanners({required this.alerts, required this.categoriesById});

  final List<BudgetStatus> alerts;
  final Map<int, CategoryEntity> categoriesById;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final status in alerts) ...[
          Material(
            color: (status.level == BudgetLevel.exceeded
                    ? AppColors.expense
                    : AppColors.warning)
                .withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    status.level == BudgetLevel.exceeded
                        ? Icons.error_outline
                        : Icons.warning_amber_rounded,
                    size: 18,
                    color: status.level == BudgetLevel.exceeded
                        ? AppColors.expense
                        : AppColors.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status.level == BudgetLevel.exceeded
                          ? AlertTemplates.budgetExceeded(
                              _nameOf(categoriesById, status.categoryId),
                              status.percent,
                            )
                          : AlertTemplates.budgetReached(
                              _nameOf(categoriesById, status.categoryId),
                              status.percent,
                            ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Barras de progresso por categoria: gasto vs. limite + saldo restante
/// (S6-02/S6-04).
class _ProgressList extends StatelessWidget {
  const _ProgressList({
    required this.statuses,
    required this.categoriesById,
  });

  final List<BudgetStatus> statuses;
  final Map<int, CategoryEntity> categoriesById;

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Nenhuma categoria com limite definido',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final status in statuses) ...[
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorFromHex(
                  categoriesById[status.categoryId]?.color,
                ).withValues(alpha: 0.2),
                child: Icon(
                  iconFromName(categoriesById[status.categoryId]?.icon),
                  size: 16,
                  color: colorFromHex(
                    categoriesById[status.categoryId]?.color,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameOf(categoriesById, status.categoryId),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${formatCents(status.spent)} de '
                      '${formatCents(status.allocated)}',
                      style: const TextStyle(
                        fontSize: 11,
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
                    '${status.percent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _levelColor(status.level),
                    ),
                  ),
                  Text(
                    status.remaining >= 0
                        ? 'Restam ${formatCents(status.remaining)}'
                        : 'Excedeu ${formatCents(-status.remaining)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: (status.percent > 100 ? 100 : status.percent) / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(_levelColor(status.level)),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Color _levelColor(BudgetLevel level) => switch (level) {
    BudgetLevel.ok => AppColors.income,
    BudgetLevel.warning => AppColors.warning,
    BudgetLevel.exceeded => AppColors.expense,
  };
}

/// Formulário de definição/ajuste do orçamento (S6-01/S6-06).
class _BudgetForm extends StatefulWidget {
  const _BudgetForm({
    required this.categories,
    required this.initialIncome,
    required this.initialAllocations,
    required this.canCopyPrevious,
    required this.onSave,
    this.onCancel,
    this.onCopyPrevious,
  });

  final List<CategoryEntity> categories;
  final int? initialIncome;
  final Map<int, int> initialAllocations;
  final bool canCopyPrevious;
  final Future<void> Function(int income, Map<int, int> allocations) onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onCopyPrevious;

  @override
  State<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<_BudgetForm> {
  final _incomeController = TextEditingController();
  final Map<int, TextEditingController> _allocationControllers = {};
  String? _incomeError;

  @override
  void initState() {
    super.initState();
    if (widget.initialIncome != null && widget.initialIncome! > 0) {
      _incomeController.text = _reais(widget.initialIncome!);
    }
    for (final category in widget.categories) {
      final value = widget.initialAllocations[category.id];
      _allocationControllers[category.id] = TextEditingController(
        text: value == null || value == 0 ? '' : _reais(value),
      );
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    for (final controller in _allocationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  static String _reais(int cents) =>
      (cents / 100).toStringAsFixed(2).replaceAll('.', ',');

  int get _income => parseCents(_incomeController.text);

  int get _allocated {
    var total = 0;
    for (final controller in _allocationControllers.values) {
      total += parseCents(controller.text);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final unallocated = _income - _allocated;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Defina sua renda mensal e distribua entre as categorias.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _incomeController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: InputDecoration(
            labelText: 'Renda total do mês',
            prefixText: 'R\$ ',
            errorText: _incomeError,
          ),
          onChanged: (_) => setState(() => _incomeError = null),
        ),
        const SizedBox(height: 20),
        for (final category in widget.categories) ...[
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorFromHex(
                  category.color,
                ).withValues(alpha: 0.2),
                child: Icon(
                  iconFromName(category.icon),
                  size: 16,
                  color: colorFromHex(category.color),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextFormField(
                  controller: _allocationControllers[category.id],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixText: 'R\$ ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Text(
          unallocated >= 0
              ? 'Não alocado: ${formatCents(unallocated)}'
              : 'Alocação excede a renda em ${formatCents(-unallocated)}',
          style: TextStyle(
            fontSize: 12,
            color: unallocated >= 0
                ? AppColors.textSecondary
                : AppColors.expense,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () async {
            if (_income <= 0) {
              setState(
                () => _incomeError = 'Informe uma renda maior que zero.',
              );
              return;
            }
            await widget.onSave(_income, {
              for (final entry in _allocationControllers.entries)
                entry.key: parseCents(entry.value.text),
            });
          },
          icon: const Icon(Icons.check),
          label: const Text('Salvar orçamento'),
        ),
        if (widget.onCancel != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Cancelar'),
          ),
        ],
        if (widget.canCopyPrevious && widget.onCopyPrevious != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: widget.onCopyPrevious,
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copiar orçamento do mês anterior'),
          ),
        ],
      ],
    );
  }
}

String _nameOf(Map<int, CategoryEntity> categoriesById, int categoryId) =>
    categoriesById[categoryId]?.name ?? 'Sem categoria';
