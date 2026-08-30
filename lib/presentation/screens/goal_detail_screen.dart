import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/goal_metrics.dart';
import '../../domain/entities/goal_entity.dart';
import '../providers/goal_provider.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');
final _monthYearFormat = DateFormat('MM/yyyy');

/// Detalhes da meta: progresso, aportes e previsão de conclusão (S7-04).
class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({super.key, required this.goal});

  final GoalEntity goal;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  final _amountController = TextEditingController();
  String? _amountError;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addContribution() async {
    final amount = parseCents(_amountController.text);
    setState(() {
      _amountError = amount <= 0 ? 'Informe um valor maior que zero.' : null;
    });
    if (amount <= 0) return;

    await ref.read(goalRepositoryProvider).addContribution(
          goalId: widget.goal.id!,
          amount: amount,
          date: DateTime.now(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _openContributionDialog() async {
    _amountController.clear();
    setState(() => _amountError = null);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar aporte'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => TextFormField(
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: 'Valor',
              prefixText: 'R\$ ',
              errorText: _amountError,
            ),
            onChanged: (_) => setDialogState(() => _amountError = null),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: _addContribution,
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final contributions = ref.watch(goalContributionsProvider(goal.id!));
    final color = colorFromHex(goal.color);

    return Scaffold(
      appBar: AppBar(title: Text(goal.name)),
      body: contributions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: (contributionList) {
          final contributed = totalContributed(contributionList);
          final percent = progressPercent(
            targetAmount: goal.targetAmount,
            contributed: contributed,
          );
          final completed = isGoalCompleted(
            targetAmount: goal.targetAmount,
            contributed: contributed,
          );
          final projection = projectedCompletion(
            targetAmount: goal.targetAmount,
            contributions: contributionList,
            now: DateTime.now(),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Material(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: color.withValues(alpha: 0.2),
                            child: Icon(
                              iconFromName(goal.icon),
                              size: 20,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatCents(contributed),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'de ${formatCents(goal.targetAmount)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${percent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: completed
                                  ? AppColors.income
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: (percent > 100 ? 100 : percent) / 100,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(
                            completed ? AppColors.income : color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (completed)
                        const Text(
                          'Meta concluída! Parabéns!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.income,
                          ),
                        )
                      else ...[
                        Text(
                          'Faltam '
                          '${formatCents(remainingAmount(
                            targetAmount: goal.targetAmount,
                            contributed: contributed,
                          ))}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (projection != null)
                          Text(
                            'Previsão de conclusão: '
                            '${_monthYearFormat.format(projection)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (goal.deadline != null)
                          Text(
                            'Prazo: ${_dateFormat.format(goal.deadline!)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _openContributionDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar aporte'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Histórico de aportes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (contributionList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Nenhum aporte ainda.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                for (final contribution in contributionList)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.savings_outlined,
                          size: 16,
                          color: AppColors.income,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _dateFormat.format(contribution.date),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          formatCents(contribution.amount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.income,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
