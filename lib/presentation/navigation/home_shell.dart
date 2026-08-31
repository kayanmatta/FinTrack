import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../screens/analises_screen.dart';
import '../screens/configuracoes_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/extrato_screen.dart';
import '../screens/fixos_screen.dart';
import '../screens/metas_screen.dart';
import '../screens/orcamento_screen.dart';
import '../screens/transaction_form_screen.dart';
import '../widgets/notifications_bell.dart';

/// Destino da navegação principal.
class _Destination {
  const _Destination(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Itens de navegação (sidebar desktop e barra mobile).
const List<_Destination> _destinations = [
  _Destination('Dashboard', Icons.space_dashboard_outlined),
  _Destination('Extrato', Icons.receipt_long_outlined),
  _Destination('Análises', Icons.bar_chart_outlined),
  _Destination('Orçamento', Icons.account_balance_wallet_outlined),
  _Destination('Metas', Icons.flag_outlined),
  _Destination('Fixos', Icons.event_repeat_outlined),
  _Destination('Ajustes', Icons.settings_outlined),
];

/// Estrutura principal com as sete telas do aplicativo.
///
/// Desktop (>=700px): barra lateral escura com logo e item ativo roxo.
/// Mobile: barra inferior escura com botão "+" central (mockup).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const List<Widget> _screens = [
    DashboardScreen(),
    ExtratoScreen(),
    AnalisesScreen(),
    OrcamentoScreen(),
    MetasScreen(),
    FixosScreen(),
    ConfiguracoesScreen(),
  ];

  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  Future<void> _newTransaction() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação salva.')),
    );
  }

  void _openMoreSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final i in [3, 4, 5, 6])
                  ListTile(
                    leading: Icon(
                      _destinations[i].icon,
                      color: _index == i
                          ? AppColors.primaryLight
                          : AppColors.textSecondary,
                    ),
                    title: Text(_destinations[i].label),
                    onTap: () {
                      Navigator.of(context).pop();
                      _select(i);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _newTransaction,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add),
              label: const Text('Nova transação'),
            ),
            body: Row(
              children: [
                _Sidebar(index: _index, onSelect: _select),
                Expanded(
                  child: IndexedStack(index: _index, children: _screens),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          body: IndexedStack(index: _index, children: _screens),
          bottomNavigationBar: _MobileBar(
            index: _index,
            onSelect: _select,
            onNew: _newTransaction,
            onMore: _openMoreSheet,
          ),
        );
      },
    );
  }
}

/// Barra lateral desktop no estilo do mockup: logo, itens e sino.
class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      color: AppColors.sidebar,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/logo.png',
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < _destinations.length; i++) _item(i),
          const Spacer(),
          const NotificationsBell(),
        ],
      ),
    );
  }

  Widget _item(int i) {
    final destination = _destinations[i];
    final selected = i == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelect(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  destination.icon,
                  size: 20,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  destination.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra inferior mobile: 4 abas + botão "+" central (mockup).
///
/// Orçamento, Metas, Fixos e Ajustes ficam no sheet "Mais".
class _MobileBar extends StatelessWidget {
  const _MobileBar({
    required this.index,
    required this.onSelect,
    required this.onNew,
    required this.onMore,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onNew;
  final VoidCallback onMore;

  bool get _moreActive => index >= 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebar,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _barItem(context, 0),
              _barItem(context, 1),
              SizedBox(
                width: 64,
                child: Center(
                  child: Tooltip(
                    message: 'Nova transação',
                    child: GestureDetector(
                      onTap: onNew,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              _barItem(context, 2),
              _moreItem(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barItem(BuildContext context, int i) {
    final selected = index == i;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _destinations[i].icon,
              size: 22,
              color: selected ? AppColors.primaryLight : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              i == 0 ? 'Início' : _destinations[i].label,
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreItem(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onMore,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _moreActive ? _destinations[index].icon : Icons.more_horiz,
              size: 22,
              color: _moreActive
                  ? AppColors.primaryLight
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              _moreActive ? _destinations[index].label : 'Mais',
              style: TextStyle(
                fontSize: 10,
                color: _moreActive
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
