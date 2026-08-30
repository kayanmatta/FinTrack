import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/alert_entity.dart';
import '../providers/alert_provider.dart';

/// Central de notificações com os alertas pendentes (S8-01).
class NotificacoesScreen extends ConsumerWidget {
  const NotificacoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(pendingAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final pending = ref.watch(pendingAlertsProvider).valueOrNull;
              if (pending == null || pending.isEmpty) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () async {
                  await ref
                      .read(alertRepositoryProvider)
                      .markRead([for (final alert in pending) alert.key]);
                },
                child: const Text('Marcar todas como lidas'),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: alerts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        data: (pending) {
          if (pending.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhuma notificação pendente.\n'
                  'Novos alertas sobre seus gastos aparecerão aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _AlertTile(alert: pending[index]),
          );
        },
      ),
    );
  }
}

/// Card de um alerta com ícone e cor conforme a severidade.
class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final AlertEntity alert;

  (IconData, Color) get _visual => switch (alert.severity) {
    AlertSeverity.danger => (Icons.error_outline, AppColors.expense),
    AlertSeverity.warning => (Icons.warning_amber_rounded, AppColors.warning),
    AlertSeverity.info => (Icons.info_outline, AppColors.info),
    AlertSeverity.positive => (Icons.savings_outlined, AppColors.income),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _visual;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
