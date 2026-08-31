import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/data/services/backup_file_manager.dart';
import 'package:fintrack/domain/repositories/backup_repository.dart';
import 'package:fintrack/presentation/providers/backup_provider.dart';
import 'package:fintrack/presentation/screens/configuracoes_screen.dart';

/// Repositório fake de backup que registra o conteúdo importado.
class FakeBackupRepository implements BackupRepository {
  String exportContent = '{"app":"Centivo","format":1,"data":{}}';
  String? imported;

  @override
  Future<String> exportBackup() async => exportContent;

  @override
  Future<void> importBackup(String content) async {
    if (content == 'INVALID') {
      throw const FormatException('não é um backup');
    }
    imported = content;
  }
}

/// Gerenciador de arquivos fake (sem canal de plataforma).
class FakeBackupFileManager implements BackupFileManager {
  String? savedContent;
  String? savedName;
  String? readContent = '{"app":"Centivo","format":1,"data":{}}';

  @override
  Future<String?> saveBackup(String suggestedName, String content) async {
    savedName = suggestedName;
    savedContent = content;
    return 'C:/Backups/$suggestedName';
  }

  @override
  Future<String?> readBackup() async => readContent;
}

Future<void> _pumpConfiguracoes(
  WidgetTester tester, {
  required FakeBackupRepository repository,
  required FakeBackupFileManager fileManager,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        backupRepositoryProvider.overrideWithValue(repository),
        backupFileManagerProvider.overrideWithValue(fileManager),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: ConfiguracoesScreen()),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('Exporta o backup para um arquivo .json', (tester) async {
    final repository = FakeBackupRepository();
    final fileManager = FakeBackupFileManager();
    await _pumpConfiguracoes(
      tester,
      repository: repository,
      fileManager: fileManager,
    );

    await tester.tap(find.text('Exportar backup'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(fileManager.savedContent, repository.exportContent);
    expect(fileManager.savedName, startsWith('centivo-backup-'));
    expect(fileManager.savedName, endsWith('.json'));
    expect(
      find.textContaining('Backup salvo em C:/Backups/'),
      findsOneWidget,
    );
  });

  testWidgets('Restaura backup após confirmação', (tester) async {
    final repository = FakeBackupRepository();
    final fileManager = FakeBackupFileManager();
    await _pumpConfiguracoes(
      tester,
      repository: repository,
      fileManager: fileManager,
    );

    await tester.tap(find.text('Restaurar backup'));
    await tester.pumpAndSettle();

    // Diálogo de confirmação antes de substituir os dados.
    expect(find.text('Restaurar backup?'), findsOneWidget);
    expect(repository.imported, isNull);

    await tester.tap(find.text('Restaurar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.imported, fileManager.readContent);
    expect(find.text('Backup restaurado com sucesso.'), findsOneWidget);
  });

  testWidgets('Cancelar a confirmação não restaura nada', (tester) async {
    final repository = FakeBackupRepository();
    final fileManager = FakeBackupFileManager();
    await _pumpConfiguracoes(
      tester,
      repository: repository,
      fileManager: fileManager,
    );

    await tester.tap(find.text('Restaurar backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(repository.imported, isNull);
    expect(fileManager.readContent, isNotNull);
  });

  testWidgets('Arquivo inválido mostra erro e não altera os dados', (
    tester,
  ) async {
    final repository = FakeBackupRepository();
    final fileManager = FakeBackupFileManager()..readContent = 'INVALID';
    await _pumpConfiguracoes(
      tester,
      repository: repository,
      fileManager: fileManager,
    );

    await tester.tap(find.text('Restaurar backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.imported, isNull);
    expect(
      find.text('Arquivo inválido: não é um backup do Centivo.'),
      findsOneWidget,
    );
  });
}
