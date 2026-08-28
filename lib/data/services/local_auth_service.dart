import 'package:local_auth/local_auth.dart';

import '../../domain/services/auth_service.dart';

/// Autenticação biométrica usando os recursos nativos do dispositivo
/// (impressão digital, Face ID ou Windows Hello).
class LocalAuthService implements AuthService {
  LocalAuthService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      if (!await _localAuth.canCheckBiometrics) return false;
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      // Plataforma sem suporte ao plugin (ex.: testes): sem biometria.
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      // Sem biometria configurada, plugin não suportado na plataforma,
      // ou erro de plataforma: trata como não autenticado.
      return false;
    }
  }
}
