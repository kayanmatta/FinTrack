import 'package:flutter/material.dart';

import 'categories_screen.dart';

/// Preferências e cadastros do aplicativo (S8).
class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.label_outline),
          title: const Text('Categorias'),
          subtitle: const Text('Ícones e cores das movimentações'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            );
          },
        ),
        const ListTile(
          leading: Icon(Icons.account_balance_wallet_outlined),
          title: Text('Contas'),
          subtitle: Text('Contas financeiras do usuário'),
          trailing: Text('Em breve'),
        ),
      ],
    );
  }
}
