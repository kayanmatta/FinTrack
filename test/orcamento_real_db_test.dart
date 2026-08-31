import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/data/database/app_database.dart';
import 'package:fintrack/data/repositories/category_repository_impl.dart';
import 'package:fintrack/presentation/providers/database_provider.dart';
import 'package:fintrack/presentation/screens/orcamento_screen.dart';

/// Regressão: o formulário de orçamento deve salvar no banco REAL
/// (Drift) e exibir os totais em seguida — caminho usado no dispositivo.
void main() {
  testWidgets('Salva orçamento no banco real e exibe totais', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // Mesmo seed do startupProvider no app real.
    await CategoryRepositoryImpl(db).ensureDefaultCategories();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const OrcamentoScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Renda e duas alocações.
    await tester.enterText(find.byType(TextFormField).first, '1500');
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), '500');
    await tester.enterText(fields.at(2), '300');
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Salvar orçamento'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Salvar orçamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Saiu do formulário e mostra os totais alocados do banco real.
    expect(find.text('Alocado'), findsOneWidget);
    // Alocado e Disponível (sem gastos, disponível = alocado).
    expect(find.text('R\$ 800,00'), findsNWidgets(2));
    expect(find.text('R\$ 0,00 de R\$ 500,00'), findsOneWidget);
    expect(find.text('R\$ 0,00 de R\$ 300,00'), findsOneWidget);

    // Derruba a árvore dentro do próprio teste: o cancelamento dos
    // streams do drift agenda timers de duração zero que o
    // flutter_test não aceita deixar pendentes no teardown.
    // O pump com duração é o que dispara esses timers.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));

    // Os dados precisam estar persistidos no banco real.
    final rows = await db.select(db.budgets).get();
    expect(rows, hasLength(2));
    final incomes = await db.select(db.budgetIncomes).get();
    expect(incomes.single.amount, 150000);
  });
}
