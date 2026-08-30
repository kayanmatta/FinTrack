import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Card de resumo do dashboard: título, valor e variação % vs mês anterior.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    this.change,
    this.goodWhenPositive = true,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  /// Variação percentual vs mês anterior (`null` = indefinida).
  final double? change;

  /// Se `true`, variação positiva é exibida em verde (receitas, economia).
  /// Se `false`, variação positiva é vermelha (despesas subiram = ruim).
  final bool goodWhenPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _ChangeBadge(change: change, goodWhenPositive: goodWhenPositive),
        ],
      ),
    );
  }
}

/// Selo de variação percentual com cor e seta indicando a direção.
class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.change, required this.goodWhenPositive});

  final double? change;
  final bool goodWhenPositive;

  @override
  Widget build(BuildContext context) {
    if (change == null) {
      return const Text(
        'Sem base de comparação',
        style: TextStyle(color: AppColors.textDisabled, fontSize: 11),
      );
    }
    final rising = change! >= 0;
    final isGood = rising == goodWhenPositive;
    final color = isGood ? AppColors.income : AppColors.expense;
    final label = change!.abs().toStringAsFixed(1).replaceAll('.', ',');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          rising ? Icons.arrow_upward : Icons.arrow_downward,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          '$label% vs mês anterior',
          style: TextStyle(color: color, fontSize: 11),
        ),
      ],
    );
  }
}
