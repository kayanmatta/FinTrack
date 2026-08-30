import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/backup_repository_impl.dart';
import '../../data/services/backup_file_manager.dart';
import '../../domain/repositories/backup_repository.dart';
import 'database_provider.dart';

/// Serviço de exportação/importação do backup completo.
final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Acesso ao sistema de arquivos para o arquivo de backup.
final backupFileManagerProvider =
    Provider<BackupFileManager>((ref) => BackupFileManagerImpl());
