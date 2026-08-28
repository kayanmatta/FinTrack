import 'package:flutter/material.dart';

import '../screens/analises_screen.dart';
import '../screens/configuracoes_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/extrato_screen.dart';
import '../screens/metas_screen.dart';
import '../screens/orcamento_screen.dart';

/// Destino da navegação principal.
class _Destination {
  const _Destination(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Estrutura principal com as seis telas do aplicativo.
///
/// Em telas largas (Windows/desktop) usa barra lateral;
/// em telas estreitas (celulares) usa barra inferior.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const List<_Destination> _destinations = [
    _Destination('Início', Icons.space_dashboard_outlined),
    _Destination('Extrato', Icons.receipt_long_outlined),
    _Destination('Análises', Icons.bar_chart_outlined),
    _Destination('Orçamento', Icons.account_balance_wallet_outlined),
    _Destination('Metas', Icons.flag_outlined),
    _Destination('Ajustes', Icons.settings_outlined),
  ];

  static const List<Widget> _screens = [
    DashboardScreen(),
    ExtratoScreen(),
    AnalisesScreen(),
    OrcamentoScreen(),
    MetasScreen(),
    ConfiguracoesScreen(),
  ];

  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(index: _index, children: _screens),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          body: IndexedStack(index: _index, children: _screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            destinations: [
              for (final d in _destinations)
                NavigationDestination(icon: Icon(d.icon), label: d.label),
            ],
          ),
        );
      },
    );
  }
}
