import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/local_auth_service.dart';
import '../../domain/services/auth_service.dart';

/// Serviço de autenticação local exposto para a camada de apresentação.
final authServiceProvider = Provider<AuthService>((ref) {
  return LocalAuthService();
});

/// Disponibilidade de biometria no dispositivo atual.
final biometricAvailableProvider = FutureProvider<bool>((ref) {
  return ref.watch(authServiceProvider).isBiometricAvailable();
});
