import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/finance_metrics.dart';
import '../../core/utils/month_names.dart';

/// Gráfico de barras com a comparação de despesas dos últimos 6 meses
/// (S5-03). O mês de referência é o último ponto.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key, required this.evolution});

  final List<MonthlyTotal> evolution;

  @override
  Widget build(BuildContext context) {
    if (evolution.isEmpty) {
      return const Center(
        child: Text(
          'Sem despesas registradas',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    final maxReais =
        evolution.map((month) => month.amount / 100).reduce(
              (a, b) => a > b ? a : b,
            ) *
        1.25;
    final lastIndex = evolution.length - 1;

    return BarChart(
      BarChartData(
        maxY: maxReais == 0 ? 1 : maxReais,
        barTouchData: BarTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) => Text(
                _compact(value),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                // Ignora posições fracionárias para não duplicar rótulos.
                if (value != index.toDouble() ||
                    index < 0 ||
                    index >= evolution.length) {
                  return const SizedBox.shrink();
                }
                final month = evolution[index].month;
                final isLast = index == lastIndex;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    monthShortNames[month.month - 1],
                    style: TextStyle(
                      color: isLast
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight:
                          isLast ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var index = 0; index < evolution.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: evolution[index].amount / 100,
                  color: index == lastIndex
                      ? AppColors.primaryLight
                      : AppColors.primary,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Formata valores em reais de forma compacta (ex.: 1,2k).
  String _compact(double reais) {
    if (reais >= 1000) {
      return '${(reais / 1000).toStringAsFixed(1).replaceAll('.', ',')}k';
    }
    return reais.toStringAsFixed(0);
  }
}
