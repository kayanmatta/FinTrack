import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// Acesso ao sistema de arquivos para salvar/abrir o arquivo de backup.
///
/// Abstração para permitir fake em testes de widget (sem canal de plataforma).
abstract class BackupFileManager {
  /// Abre o diálogo de "salvar como" e grava [content].
  ///
  /// Retorna o caminho salvo, ou `null` se o usuário cancelou.
  Future<String?> saveBackup(String suggestedName, String content);

  /// Abre o diálogo de seleção e lê o conteúdo do arquivo escolhido.
  ///
  /// Retorna o conteúdo, ou `null` se o usuário cancelou.
  Future<String?> readBackup();
}

/// Implementação real via file_picker (Android, Windows e demais plataformas).
class BackupFileManagerImpl implements BackupFileManager {
  @override
  Future<String?> saveBackup(String suggestedName, String content) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar backup do FinTrack',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (path == null) return null;
    await File(path).writeAsString(content);
    return path;
  }

  @override
  Future<String?> readBackup() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Selecionar backup do FinTrack',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    return File(path).readAsString();
  }
}
