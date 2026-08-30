import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../providers/alert_provider.dart';
import '../screens/notificacoes_screen.dart';

/// Sino com badge de alertas pendentes (S8-01).
///
/// Usado no topo das telas estreitas e na barra lateral do desktop.
class NotificationsBell extends ConsumerWidget {
  const NotificationsBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingAlertsProvider).valueOrNull ?? const [];

    return IconButton(
      tooltip: 'Notificações',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
        );
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          if (pending.isNotEmpty)
            Positioned(
              right: -4,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.expense,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  pending.length > 9 ? '9+' : '${pending.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, height: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
