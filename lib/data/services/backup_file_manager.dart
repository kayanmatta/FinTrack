import 'dart:convert';

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
    // No file_picker 12+, o próprio plugin grava os bytes no destino escolhido.
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Salvar backup do FinTrack',
      fileName: suggestedName,
      bytes: utf8.encode(content),
      mimeType: 'application/json',
    );
    return uri?.toString();
  }

  @override
  Future<String?> readBackup() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Selecionar backup do FinTrack',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    return utf8.decode(await file.readAsBytes());
  }
}
