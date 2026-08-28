import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
import 'transaction_form_screen.dart';

/// Períodos de filtro disponíveis.
enum _Period { all, month, days30, days7 }

const Map<_Period, String> _periodLabels = {
  _Period.all: 'Todo o período',
  _Period.month: 'Este mês',
  _Period.days30: 'Últimos 30 dias',
  _Period.days7: 'Últimos 7 dias',
};

/// Extrato com busca, filtros, ordenação e visualização lista/tabela (S3-06).
class ExtratoScreen extends StatefulWidget {
  const ExtratoScreen({super.key});

  @override
  State<ExtratoScreen> createState() => _ExtratoScreenState();
}

class _ExtratoScreenState extends State<ExtratoScreen> {
  final _searchController = TextEditingController();

  String _query = '';
  String _typeFilter = 'todos';
  int? _categoryFilter;
  int? _accountFilter;
  _Period _period = _Period.all;
  bool _descending = true;
  bool _tableView = false;

  bool get _hasActiveFilters =>
      _typeFilter != 'todos' ||
      _categoryFilter != null ||
      _accountFilter != null ||
      _period != _Period.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _typeFilter = 'todos';
      _categoryFilter = null;
      _accountFilter = null;
      _period = _Period.all;
    });
  }

  bool _matchesPeriod(DateTime date, DateTime now) {
    switch (_period) {
      case _Period.all:
        return true;
      case _Period.month:
        return date.year == now.year && date.month == now.month;
      case _Period.days30:
        return !date.isBefore(now.subtract(const Duration(days: 30)));
      case _Period.days7:
        return !date.isBefore(now.subtract(const Duration(days: 7)));
    }
  }

  List<TransactionEntity> _applyFilters(
    List<TransactionEntity> items,
    Map<int, CategoryEntity> categoriesById,
    Map<int, AccountEntity> accountsById,
  ) {
    final now = DateTime.now();
    final query = _query.toLowerCase();
    final filtered = [
      for (final transaction in items)
        if (_typeFilter == 'todos' || transaction.type == _typeFilter)
          if (_categoryFilter == null ||
              transaction.categoryId == _categoryFilter)
            if (_accountFilter == null ||
                transaction.accountId == _accountFilter)
              if (_matchesPeriod(transaction.date, now))
                if (query.isEmpty || _matchesQuery(
                  transaction,
                  categoriesById,
                  accountsById,
                  query,
                ))
                  transaction,
    ];
    filtered.sort((a, b) => _descending
        ? b.date.compareTo(a.date)
        : a.date.compareTo(b.date));
    return filtered;
  }

  bool _matchesQuery(
    TransactionEntity transaction,
    Map<int, CategoryEntity> categoriesById,
    Map<int, AccountEntity> accountsById,
    String query,
  ) {
    final description = (transaction.description ?? '').toLowerCase();
    final categoryName =
        categoriesById[transaction.categoryId]?.name.toLowerCase() ?? '';
    final accountName =
        accountsById[transaction.accountId]?.name.toLowerCase() ?? '';
    return description.contains(query) ||
        categoryName.contains(query) ||
        accountName.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final transactions = ref.watch(transactionsProvider);
        final categories = ref.watch(categoriesProvider);
        final accounts = ref.watch(accountsProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Extrato'),
            actions: [
              IconButton(
                tooltip: _descending ? 'Mais recentes primeiro' : 'Mais antigas primeiro',
                onPressed: () => setState(() => _descending = !_descending),
                icon: Icon(
                  _descending ? Icons.arrow_downward : Icons.arrow_upward,
                ),
              ),
              IconButton(
                tooltip: _tableView ? 'Ver em lista' : 'Ver em tabela',
                onPressed: () => setState(() => _tableView = !_tableView),
                icon: Icon(_tableView ? Icons.view_list : Icons.table_chart),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por descrição, categoria ou conta',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() => _query = value.trim()),
                ),
              ),
              _FilterBar(
                typeFilter: _typeFilter,
                onTypeChanged: (value) =>
                    setState(() => _typeFilter = value),
                categoryFilter: _categoryFilter,
                accountFilter: _accountFilter,
                period: _period,
                categories: categories.valueOrNull ?? const [],
                accounts: accounts.valueOrNull ?? const [],
                onCategorySelected: (value) =>
                    setState(() => _categoryFilter = value),
                onAccountSelected: (value) =>
                    setState(() => _accountFilter = value),
                onPeriodSelected: (value) => setState(() => _period = value),
                hasActiveFilters: _hasActiveFilters,
                onClearFilters: _clearFilters,
              ),
              Expanded(
                child: transactions.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Erro ao carregar: $error')),
                  data: (items) {
                    if (items.isEmpty) return const _EmptyState();
                    final categoriesById = {
                      for (final c in categories.valueOrNull ?? <CategoryEntity>[])
                        c.id: c,
                    };
                    final accountsById = {
                      for (final a in accounts.valueOrNull ?? <AccountEntity>[])
                        a.id: a,
                    };
                    final filtered = _applyFilters(
                      items,
                      categoriesById,
                      accountsById,
                    );
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma transação encontrada.'),
                      );
                    }
                    if (_tableView) {
                      return _TransactionTable(
                        transactions: filtered,
                        categoriesById: categoriesById,
                        accountsById: accountsById,
                      );
                    }
                    return _TransactionList(
                      transactions: filtered,
                      categoriesById: categoriesById,
                      accountsById: accountsById,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Barra de filtros: tipo, categoria, conta e período.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.typeFilter,
    required this.onTypeChanged,
    required this.categoryFilter,
    required this.accountFilter,
    required this.period,
    required this.categories,
    required this.accounts,
    required this.onCategorySelected,
    required this.onAccountSelected,
    required this.onPeriodSelected,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final String typeFilter;
  final ValueChanged<String> onTypeChanged;
  final int? categoryFilter;
  final int? accountFilter;
  final _Period period;
  final List<CategoryEntity> categories;
  final List<AccountEntity> accounts;
  final ValueChanged<int?> onCategorySelected;
  final ValueChanged<int?> onAccountSelected;
  final ValueChanged<_Period> onPeriodSelected;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final categoryName = categoryFilter == null
        ? 'Categoria'
        : categories.where((c) => c.id == categoryFilter).isEmpty
            ? 'Categoria'
            : categories
                .firstWhere((c) => c.id == categoryFilter)
                .name;
    final accountName = accountFilter == null
        ? 'Conta'
        : accounts.where((a) => a.id == accountFilter).isEmpty
            ? 'Conta'
            : accounts.firstWhere((a) => a.id == accountFilter).name;

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          ChoiceChip(
            label: const Text('Todas'),
            selected: typeFilter == 'todos',
            onSelected: (_) => onTypeChanged('todos'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Receitas'),
            selected: typeFilter == 'receita',
            onSelected: (_) => onTypeChanged('receita'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Despesas'),
            selected: typeFilter == 'despesa',
            onSelected: (_) => onTypeChanged('despesa'),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<int?>(
            initialValue: categoryFilter,
            tooltip: 'Filtrar por categoria',
            onSelected: onCategorySelected,
            itemBuilder: (context) => [
              const PopupMenuItem<int?>(value: null, child: Text('Todas')),
              for (final category in categories)
                PopupMenuItem(value: category.id, child: Text(category.name)),
            ],
            child: InputChip(
              label: Text(categoryName),
              selected: categoryFilter != null,
              onSelected: (_) {},
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<int?>(
            initialValue: accountFilter,
            tooltip: 'Filtrar por conta',
            onSelected: onAccountSelected,
            itemBuilder: (context) => [
              const PopupMenuItem<int?>(value: null, child: Text('Todas')),
              for (final account in accounts)
                PopupMenuItem(value: account.id, child: Text(account.name)),
            ],
            child: InputChip(
              label: Text(accountName),
              selected: accountFilter != null,
              onSelected: (_) {},
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<_Period>(
            initialValue: period,
            tooltip: 'Filtrar por período',
            onSelected: onPeriodSelected,
            itemBuilder: (context) => [
              for (final entry in _periodLabels.entries)
                PopupMenuItem(value: entry.key, child: Text(entry.value)),
            ],
            child: InputChip(
              label: Text(_periodLabels[period]!),
              selected: period != _Period.all,
              onSelected: (_) {},
            ),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.clear, size: 18),
              label: const Text('Limpar'),
              onPressed: onClearFilters,
            ),
          ],
        ],
      ),
    );
  }
}

/// Visualização em lista agrupada por dia.
class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.transactions,
    required this.categoriesById,
    required this.accountsById,
  });

  final List<TransactionEntity> transactions;
  final Map<int, CategoryEntity> categoriesById;
  final Map<int, AccountEntity> accountsById;

  Map<DateTime, List<TransactionEntity>> _groupByDay() {
    final groups = <DateTime, List<TransactionEntity>>{};
    for (final transaction in transactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      groups.putIfAbsent(day, () => []).add(transaction);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDay();
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionFormScreen(initial: transaction),
          ),
        );
      },
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

/// Visualização em tabela (Data, Descrição, Categoria, Conta, Valor).
class _TransactionTable extends StatelessWidget {
  const _TransactionTable({
    required this.transactions,
    required this.categoriesById,
    required this.accountsById,
  });

  final List<TransactionEntity> transactions;
  final Map<int, CategoryEntity> categoriesById;
  final Map<int, AccountEntity> accountsById;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Data')),
            DataColumn(label: Text('Descrição')),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Conta')),
            DataColumn(label: Text('Valor'), numeric: true),
          ],
          rows: [
            for (final transaction in transactions)
              DataRow(
                onSelectChanged: (_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          TransactionFormScreen(initial: transaction),
                    ),
                  );
                },
                cells: [
                  DataCell(
                    Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
                  ),
                  DataCell(
                    Text(
                      transaction.description ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      categoriesById[transaction.categoryId]?.name ??
                          'Sem categoria',
                    ),
                  ),
                  DataCell(
                    Text(accountsById[transaction.accountId]?.name ?? '—'),
                  ),
                  DataCell(
                    Text(
                      '${transaction.isIncome ? '+' : '-'} '
                      '${formatCents(transaction.amount)}',
                      style: TextStyle(
                        color: transaction.isIncome
                            ? AppColors.income
                            : AppColors.expense,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
          ],
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
