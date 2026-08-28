import 'package:flutter/material.dart';

import '../widgets/feature_placeholder.dart';

/// Lista de receitas e despesas registradas (S3/S5).
class ExtratoScreen extends StatelessWidget {
  const ExtratoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Extrato',
      icon: Icons.receipt_long_outlined,
    );
  }
}
