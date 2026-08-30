import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/alert_repository_impl.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import 'database_provider.dart';

/// Repositório da central de notificações (camada de apresentação).
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Alertas vigentes ainda não lidos (S8-01).
final pendingAlertsProvider = StreamProvider<List<AlertEntity>>((ref) {
  return ref.watch(alertRepositoryProvider).watchPending();
});
