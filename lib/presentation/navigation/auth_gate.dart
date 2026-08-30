import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/startup_provider.dart';
import '../providers/security_provider.dart';
import '../screens/login_screen.dart';
import 'home_shell.dart';

/// Decide entre a tela de bloqueio e o aplicativo liberado,
/// após a inicialização (banco + dados padrão).
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(startupProvider);
    return startup.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Erro ao iniciar: $error')),
      ),
      data: (_) {
        final unlocked = ref.watch(isUnlockedProvider);
        return unlocked ? const HomeShell() : const LoginScreen();
      },
    );
  }
}
