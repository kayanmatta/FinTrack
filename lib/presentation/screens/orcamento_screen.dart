import 'package:flutter/material.dart';

import '../widgets/feature_placeholder.dart';

/// Limites mensais por categoria (S7).
class OrcamentoScreen extends StatelessWidget {
  const OrcamentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Orçamento',
      icon: Icons.account_balance_wallet_outlined,
    );
  }
}
