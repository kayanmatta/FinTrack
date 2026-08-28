import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'category_provider.dart';
import 'database_provider.dart';

/// Inicialização do aplicativo: banco pronto e dados padrão semeados.
final startupProvider = FutureProvider<void>((ref) async {
  await ref.watch(databaseRepositoryProvider).ensureReady();
  await ref.watch(categoryRepositoryProvider).ensureDefaultCategories();
});
