import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fintrack/main.dart';

/// Simula um dispositivo sem biometria para o plugin local_auth.
void _mockLocalAuthChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/local_auth'),
    (call) async {
      switch (call.method) {
        case 'getAvailableBiometrics':
          return <String>[];
        case 'isDeviceSupported':
        case 'authenticate':
        case 'stopAuthentication':
          return false;
        default:
          return null;
      }
    },
  );
}

Future<void> _typePin(WidgetTester tester, List<String> digits) async {
  for (final digit in digits) {
    await tester.tap(find.text(digit));
    await tester.pump();
  }
}

/// Aguarda o carregamento inicial da tela de login sem travar
/// no spinner de loading (animação infinita).
Future<void> _awaitLoginReady(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('Primeiro acesso cria PIN e desbloqueia o app', (tester) async {
    SharedPreferences.setMockInitialValues({});
    _mockLocalAuthChannel();
    await tester.pumpWidget(const ProviderScope(child: FinTrackApp()));
    await _awaitLoginReady(tester);
    expect(find.text('Criar PIN'), findsOneWidget);

    await _typePin(tester, ['1', '2', '3', '4']);
    expect(find.text('Confirmar PIN'), findsOneWidget);

    await _typePin(tester, ['1', '2', '3', '4']);
    await tester.pump();
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('Navega para a tela de metas após desbloquear', (tester) async {
    SharedPreferences.setMockInitialValues({});
    _mockLocalAuthChannel();
    await tester.pumpWidget(const ProviderScope(child: FinTrackApp()));
    await _awaitLoginReady(tester);
    await _typePin(tester, ['1', '2', '3', '4']);
    await _typePin(tester, ['1', '2', '3', '4']);
    await tester.pump();

    await tester.tap(find.text('Metas'));
    await tester.pump();
    // Rótulo na barra lateral + título da tela.
    expect(find.text('Metas'), findsNWidgets(2));
  });
}
