import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/security_provider.dart';
import '../screens/login_screen.dart';
import 'home_shell.dart';

/// Decide entre a tela de bloqueio e o aplicativo liberado.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(isUnlockedProvider);
    return unlocked ? const HomeShell() : const LoginScreen();
  }
}
