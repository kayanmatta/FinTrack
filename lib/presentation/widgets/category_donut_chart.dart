import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/finance_metrics.dart';
import '../../domain/entities/category_entity.dart';

/// Donut de gastos do mês por categoria, com legenda (S4-02).
class CategoryDonutChart extends StatelessWidget {
  const CategoryDonutChart({
    super.key,
    required this.spending,
    required this.categoriesById,
  });

  final List<CategorySpending> spending;
  final Map<int, CategoryEntity> categoriesById;

  Color _colorFor(int? categoryId) => categoryId == null
      ? AppColors.textDisabled
      : colorFromHex(categoriesById[categoryId]?.color ?? '#6B7280');

  @override
  Widget build(BuildContext context) {
    if (spending.isEmpty) {
      return const Center(
        child: Text(
          'Sem despesas neste mês',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 48,
              sectionsSpace: 2,
              sections: [
                for (final item in spending)
                  PieChartSectionData(
                    value: item.amount.toDouble(),
                    color: _colorFor(item.categoryId),
                    title: '${item.percentage.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    radius: 36,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final item in spending)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _colorFor(item.categoryId),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categoriesById[item.categoryId]?.name ?? 'Sem categoria',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  formatCents(item.amount),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${item.percentage.toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
