import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/main.dart';

void main() {
  testWidgets('Exibe o dashboard na navegação principal', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FinTrackApp()));
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('Navega para a tela de metas', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FinTrackApp()));
    await tester.tap(find.text('Metas'));
    await tester.pump();
    // Rótulo na barra lateral + título da tela.
    expect(find.text('Metas'), findsNWidgets(2));
  });
}
