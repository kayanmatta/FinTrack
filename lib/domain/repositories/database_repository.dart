/// Contrato de acesso ao banco de dados local (camada de domínio).
///
/// A camada de domínio não conhece Drift/SQLite diretamente;
/// ela apenas define o que a aplicação precisa do banco.
abstract class DatabaseRepository {
  /// Garante que o banco foi criado e está pronto para uso.
  Future<void> ensureReady();
}
