import 'package:flutter/material.dart';

import '../widgets/feature_placeholder.dart';

/// Preferências do aplicativo (S8).
class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Configurações',
      icon: Icons.settings_outlined,
    );
  }
}
