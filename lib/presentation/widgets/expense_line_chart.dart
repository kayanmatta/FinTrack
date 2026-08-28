import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/finance_metrics.dart';
import '../../core/utils/month_names.dart';

/// Linha de evolução de despesas dos últimos meses (S4-03).
///
/// O mês atual é o último ponto e recebe destaque maior.
class ExpenseLineChart extends StatelessWidget {
  const ExpenseLineChart({super.key, required this.evolution});

  final List<MonthlyTotal> evolution;

  @override
  Widget build(BuildContext context) {
    final maxY = evolution
            .map((m) => m.amount)
            .fold<int>(0, (a, b) => a > b ? a : b)
            .toDouble() /
        100;
    final hasData = evolution.any((m) => m.amount > 0);
    if (!hasData) {
      return const Center(
        child: Text(
          'Sem despesas registradas',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    final lastIndex = evolution.length - 1;
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.25,
        minX: 0,
        maxX: lastIndex.toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              interval: maxY / 4,
              getTitlesWidget: (value, meta) => Text(
                _compact(value),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= evolution.length) {
                  return const SizedBox.shrink();
                }
                final month = evolution[index].month;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    monthShortNames[month.month - 1],
                    style: TextStyle(
                      fontSize: 10,
                      color: index == lastIndex
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: index == lastIndex
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < evolution.length; i++)
                FlSpot(i.toDouble(), evolution[i].amount / 100),
            ],
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppColors.expense,
            barWidth: 2.5,
            dotData: FlDotData(
              getDotPainter: (spot, xPercentage, barData, index) =>
                  FlDotCirclePainter(
                    radius: index == lastIndex ? 6 : 3.5,
                    color: index == lastIndex
                        ? AppColors.expense
                        : AppColors.background,
                    strokeColor: AppColors.expense,
                    strokeWidth: 2,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.expense.withValues(alpha: 0.25),
                  AppColors.expense.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formata valores em reais de forma compacta (ex.: 1,2k).
  String _compact(double reais) {
    if (reais == 0) return '0';
    if (reais >= 1000) {
      final thousands = reais / 1000;
      return '${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1).replaceAll('.', ',')}k';
    }
    return reais.toStringAsFixed(0);
  }
}
