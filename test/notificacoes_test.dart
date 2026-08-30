import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/domain/entities/alert_entity.dart';
import 'package:fintrack/domain/repositories/alert_repository.dart';
import 'package:fintrack/presentation/providers/alert_provider.dart';
import 'package:fintrack/presentation/screens/notificacoes_screen.dart';
import 'package:fintrack/presentation/widgets/notifications_bell.dart';

/// Repositório fake da central de notificações com stream reativo.
class FakeAlertRepository implements AlertRepository {
  FakeAlertRepository(List<AlertEntity> alerts) : _alerts = [...alerts];

  final List<AlertEntity> _alerts;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<List<AlertEntity>> watchPending() async* {
    yield List.of(_alerts);
    await for (final _ in _changes.stream) {
      yield List.of(_alerts);
    }
  }

  @override
  Future<void> markRead(List<String> keys) async {
    _alerts.removeWhere((alert) => keys.contains(alert.key));
    _changes.add(null);
  }
}

Future<void> _pumpNotificacoes(
  WidgetTester tester,
  FakeAlertRepository repository, {
  Widget home = const NotificacoesScreen(),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [alertRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(theme: AppTheme.dark, home: home),
    ),
  );
  await tester.pump();
  // Frame extra para o StreamProvider emitir o primeiro valor do fake.
  await tester.pump(const Duration(milliseconds: 300));
}

List<AlertEntity> _alertasExemplo() => const [
      AlertEntity(
        key: 'orcamento-1-2026-08',
        title: 'Orçamento estourado',
        message: 'Você ultrapassou o limite de Mercado (120,0%).',
        severity: AlertSeverity.danger,
      ),
      AlertEntity(
        key: 'meta-7',
        title: 'Meta: Viagem',
        message: 'Faltam R\$ 600,00 para atingir a meta Viagem.',
        severity: AlertSeverity.info,
      ),
    ];

void main() {
  testWidgets('Lista alertas e marca todos como lidos (S8-01)', (
    tester,
  ) async {
    await _pumpNotificacoes(tester, FakeAlertRepository(_alertasExemplo()));

    expect(find.text('Orçamento estourado'), findsOneWidget);
    expect(
      find.text('Você ultrapassou o limite de Mercado (120,0%).'),
      findsOneWidget,
    );
    expect(find.text('Meta: Viagem'), findsOneWidget);

    await tester.tap(find.text('Marcar todas como lidas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Nenhuma notificação pendente'), findsOneWidget);
  });

  testWidgets('Estado vazio sem botão de leitura', (tester) async {
    await _pumpNotificacoes(tester, FakeAlertRepository(const []));

    expect(find.textContaining('Nenhuma notificação pendente'), findsOneWidget);
    expect(find.text('Marcar todas como lidas'), findsNothing);
  });

  testWidgets('Sino exibe badge com a contagem de pendentes (S8-01)', (
    tester,
  ) async {
    await _pumpNotificacoes(
      tester,
      FakeAlertRepository(_alertasExemplo()),
      home: const Scaffold(body: Center(child: NotificationsBell())),
    );

    expect(find.byTooltip('Notificações'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Sino sem badge quando não há pendências', (tester) async {
    await _pumpNotificacoes(
      tester,
      FakeAlertRepository(const []),
      home: const Scaffold(body: Center(child: NotificationsBell())),
    );

    expect(find.byTooltip('Notificações'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
