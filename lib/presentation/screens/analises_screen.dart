import 'package:flutter/material.dart';

import '../widgets/feature_placeholder.dart';

/// Gráficos e relatórios de gastos (S7).
class AnalisesScreen extends StatelessWidget {
  const AnalisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Análises',
      icon: Icons.bar_chart_outlined,
    );
  }
}
