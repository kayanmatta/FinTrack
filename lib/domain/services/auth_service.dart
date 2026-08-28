/// Contrato de autenticação local (camada de domínio).
///
/// O domínio não conhece o plugin local_auth; apenas define
/// o que a aplicação precisa para autenticar o usuário.
abstract class AuthService {
  /// Se o dispositivo possui biometria disponível e configurada.
  Future<bool> isBiometricAvailable();

  /// Executa a autenticação biométrica.
  ///
  /// Retorna `true` se o usuário foi autorizado.
  Future<bool> authenticate({required String reason});
}
