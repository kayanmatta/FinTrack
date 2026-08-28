import 'package:flutter/material.dart';

import '../widgets/feature_placeholder.dart';

/// Tela inicial com resumo financeiro (S4).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
    );
  }
}
