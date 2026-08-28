import 'package:flutter/material.dart';

import '../widgets/feature_placeholder.dart';

/// Metas de economia e aportes (S6).
class MetasScreen extends StatelessWidget {
  const MetasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Metas',
      icon: Icons.flag_outlined,
    );
  }
}
