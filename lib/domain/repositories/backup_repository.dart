/// Contrato de exportação/importação do backup completo (backlog V2).
abstract class BackupRepository {
  /// Gera o conteúdo JSON com todos os dados do aplicativo.
  Future<String> exportBackup();

  /// Substitui todos os dados atuais pelos do backup em [content].
  ///
  /// Lança [FormatException] se o conteúdo não for um backup válido.
  Future<void> importBackup(String content);
}
