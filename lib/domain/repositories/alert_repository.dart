import '../entities/alert_entity.dart';

/// Contrato da central de notificações (camada de domínio).
///
/// Os alertas são derivados dos dados atuais do usuário; apenas o estado
/// de leitura é persistido.
abstract class AlertRepository {
  /// Alertas vigentes ainda não marcados como lidos.
  Stream<List<AlertEntity>> watchPending();

  /// Marca os alertas das [keys] como lidos (some da central e do badge).
  Future<void> markRead(List<String> keys);
}
