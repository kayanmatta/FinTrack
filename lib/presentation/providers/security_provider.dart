import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/local_security_service.dart';
import '../../domain/services/security_service.dart';

/// Serviço de segurança (PIN) exposto para a camada de apresentação.
final securityServiceProvider = Provider<SecurityService>((ref) {
  return LocalSecurityService();
});

/// Se o aplicativo está desbloqueado na sessão atual.
final isUnlockedProvider = StateProvider<bool>((ref) => false);
