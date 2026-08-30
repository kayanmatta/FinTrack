/// Contrato de segurança local (camada de domínio).
///
/// Define o que a aplicação precisa para proteger o acesso
/// com PIN, sem expor detalhes de armazenamento.
abstract class SecurityService {
  /// Se já existe um PIN configurado no dispositivo.
  Future<bool> hasPin();

  /// Salva o PIN (armazenado apenas como hash).
  Future<void> setPin(String pin);

  /// Verifica se o PIN informado confere com o salvo.
  Future<bool> validatePin(String pin);
}
