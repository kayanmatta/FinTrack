import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/main.dart';

void main() {
  testWidgets('Exibe o título inicial do app', (WidgetTester tester) async {
    await tester.pumpWidget(const FinTrackApp());
    expect(find.text('FinTrack'), findsOneWidget);
  });
}
