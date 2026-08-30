/// Severidade de um alerta, para escolha de ícone/cor na UI.
enum AlertSeverity { danger, warning, info, positive }

/// Alerta exibido na central de notificações (Sprint 8).
///
/// Os alertas são derivados dos dados atuais (transações, orçamento e
/// metas) e identificados por uma [key] estável — ex.:
/// 'orcamento-3-2026-08' — que permite marcar cada um como lido.
class AlertEntity {
  const AlertEntity({
    required this.key,
    required this.title,
    required this.message,
    required this.severity,
  });

  final String key;
  final String title;
  final String message;
  final AlertSeverity severity;
}
