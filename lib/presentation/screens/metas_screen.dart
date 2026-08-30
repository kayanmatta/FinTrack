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
import 'goal_detail_screen.dart';
import 'goal_form_screen.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');

/// Lista de metas de economia com progresso e aportes (Sprint 7).
class MetasScreen extends ConsumerWidget {
  const MetasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova meta',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GoalFormScreen()),
              );
            },
          ),
        ],
      ),
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: (goalList) {
          if (goalList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhuma meta ainda.\n'
                  'Toque em + para criar sua primeira meta de economia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: goalList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _GoalCard(goal: goalList[index]),
          );
        },
      ),
    );
  }
}

/// Card de uma meta: ícone, progresso, prazo e exclusão (S7-03/S7-05/S7-06).
class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final GoalEntity goal;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir meta?'),
        content: Text('A meta "${goal.name}" e seus aportes serão excluídos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(goalRepositoryProvider).delete(goal.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributions = ref.watch(goalContributionsProvider(goal.id!));

    return contributions.when(
      loading: () => const Card(child: Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(minHeight: 4),
      )),
      error: (error, _) => Card(child: Text('Erro: $error')),
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
        final color = colorFromHex(goal.color);

        return Material(
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: completed ? AppColors.income : Colors.transparent,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GoalDetailScreen(goal: goal),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: color.withValues(alpha: 0.2),
                        child: Icon(
                          iconFromName(goal.icon),
                          size: 18,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${formatCents(contributed)} de '
                              '${formatCents(goal.targetAmount)}',
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: completed
                              ? AppColors.income
                              : AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.textSecondary,
                        ),
                        tooltip: 'Excluir meta',
                        onPressed: () => _confirmDelete(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 8),
                  if (completed)
                    const Row(
                      children: [
                        Icon(
                          Icons.celebration_outlined,
                          size: 16,
                          color: AppColors.income,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Meta concluída! Parabéns!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.income,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          goal.deadline == null
                              ? 'Sem prazo definido'
                              : 'Prazo: ${_dateFormat.format(goal.deadline!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Faltam '
                          '${formatCents(remainingAmount(
                            targetAmount: goal.targetAmount,
                            contributed: contributed,
                          ))}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
