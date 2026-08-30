import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/domain/entities/goal_entity.dart';
import 'package:fintrack/domain/repositories/goal_repository.dart';
import 'package:fintrack/presentation/providers/goal_provider.dart';
import 'package:fintrack/presentation/screens/metas_screen.dart';

/// Repositório fake de metas com estado mutável e streams reativos.
class FakeGoalRepository implements GoalRepository {
  FakeGoalRepository({
    List<GoalEntity>? goals,
    Map<int, List<GoalContributionEntity>>? contributions,
  })  : _goals = [...?goals],
        _contributions = {...?contributions};

  final List<GoalEntity> _goals;
  final Map<int, List<GoalContributionEntity>> _contributions;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _nextGoalId = 1000;
  int _nextContributionId = 1000;

  @override
  Stream<List<GoalEntity>> watchAll() async* {
    yield List.of(_goals);
    await for (final _ in _changes.stream) {
      yield List.of(_goals);
    }
  }

  @override
  Stream<List<GoalContributionEntity>> watchContributions(int goalId) async* {
    yield List.of(_contributions[goalId] ?? const []);
    await for (final _ in _changes.stream) {
      yield List.of(_contributions[goalId] ?? const []);
    }
  }

  @override
  Future<int> create({
    required String name,
    required int targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
  }) async {
    final id = _nextGoalId++;
    _goals.insert(
      0,
      GoalEntity(
        id: id,
        name: name,
        targetAmount: targetAmount,
        deadline: deadline,
        icon: icon,
        color: color,
        createdAt: DateTime.now(),
      ),
    );
    _changes.add(null);
    return id;
  }

  @override
  Future<void> delete(int id) async {
    _goals.removeWhere((goal) => goal.id == id);
    _contributions.remove(id);
    _changes.add(null);
  }

  @override
  Future<int> addContribution({
    required int goalId,
    required int amount,
    required DateTime date,
  }) async {
    final id = _nextContributionId++;
    _contributions
        .putIfAbsent(goalId, () => [])
        .insert(
          0,
          GoalContributionEntity(
            id: id,
            goalId: goalId,
            amount: amount,
            date: date,
          ),
        );
    _changes.add(null);
    return id;
  }
}

Future<void> _pumpMetas(
  WidgetTester tester,
  FakeGoalRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [goalRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(theme: AppTheme.dark, home: const MetasScreen()),
    ),
  );
  await tester.pump();
  // Frame extra para o StreamProvider emitir o primeiro valor do fake.
  await tester.pump(const Duration(milliseconds: 300));
}

/// Meta 'Viagem' de R$ 5.000 com aportes somando R$ 2.000 (40%).
GoalEntity _goalViagem() => GoalEntity(
      id: 1,
      name: 'Viagem',
      targetAmount: 500000,
      icon: 'flight',
      color: '#3B82F6',
      createdAt: DateTime.now(),
    );

List<GoalContributionEntity> _aportesViagem() {
  final now = DateTime.now();
  return [
    GoalContributionEntity(
      id: 2,
      goalId: 1,
      amount: 100000,
      date: DateTime(now.year, now.month - 1, 10),
    ),
    GoalContributionEntity(
      id: 1,
      goalId: 1,
      amount: 100000,
      date: DateTime(now.year, now.month - 2, 10),
    ),
  ];
}

void main() {
  testWidgets('Estado vazio e criação de meta pelo formulário (S7-01/03)', (
    tester,
  ) async {
    await _pumpMetas(tester, FakeGoalRepository());

    expect(find.textContaining('Nenhuma meta ainda'), findsOneWidget);

    await tester.tap(find.byTooltip('Nova meta'));
    await tester.pumpAndSettle();
    expect(find.text('Nova meta'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Reserva');
    await tester.enterText(find.byType(TextFormField).at(1), '5000,00');
    await tester.tap(find.text('Salvar meta'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Volta para a lista com o card da nova meta.
    expect(find.text('Reserva'), findsOneWidget);
    expect(find.text('R\$ 0,00 de R\$ 5.000,00'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Sem prazo definido'), findsOneWidget);
    expect(find.text('Faltam R\$ 5.000,00'), findsOneWidget);
  });

  testWidgets('Valida nome e valor alvo no formulário', (tester) async {
    await _pumpMetas(tester, FakeGoalRepository());

    await tester.tap(find.byTooltip('Nova meta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar meta'));
    await tester.pump();

    expect(find.text('Informe um nome para a meta.'), findsOneWidget);
    expect(find.text('Informe um valor maior que zero.'), findsOneWidget);
  });

  testWidgets('Card com progresso e detalhes com aportes (S7-02/04)', (
    tester,
  ) async {
    await _pumpMetas(
      tester,
      FakeGoalRepository(
        goals: [_goalViagem()],
        contributions: {1: _aportesViagem()},
      ),
    );

    expect(find.text('R\$ 2.000,00 de R\$ 5.000,00'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('Faltam R\$ 3.000,00'), findsOneWidget);

    // Abre os detalhes da meta.
    await tester.tap(find.text('Viagem'));
    await tester.pumpAndSettle();
    expect(find.text('Histórico de aportes'), findsOneWidget);
    expect(find.text('R\$ 100,00'), findsNothing);
    expect(find.textContaining('Previsão de conclusão:'), findsOneWidget);

    // Adiciona um aporte pelo diálogo.
    await tester.tap(find.text('Adicionar aporte'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '500,00');
    await tester.tap(find.text('Adicionar'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Progresso atualizado: R$ 2.500 aportados = 50%.
    expect(find.text('R\$ 2.500,00'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('R\$ 500,00'), findsOneWidget);
  });

  testWidgets('Meta concluída mostra parabéns (S7-05)', (tester) async {
    await _pumpMetas(
      tester,
      FakeGoalRepository(
        goals: [
          GoalEntity(
            id: 2,
            name: 'Reserva',
            targetAmount: 100000,
            createdAt: DateTime.now(),
          ),
        ],
        contributions: {
          2: [
            GoalContributionEntity(
              id: 1,
              goalId: 2,
              amount: 100000,
              date: DateTime.now().subtract(const Duration(days: 10)),
            ),
          ],
        },
      ),
    );

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Meta concluída! Parabéns!'), findsOneWidget);
  });

  testWidgets('Exclui meta após confirmação (S7-06)', (tester) async {
    await _pumpMetas(
      tester,
      FakeGoalRepository(goals: [_goalViagem()]),
    );

    await tester.tap(find.byTooltip('Excluir meta'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir meta?'), findsOneWidget);

    await tester.tap(find.text('Excluir'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Viagem'), findsNothing);
    expect(find.textContaining('Nenhuma meta ainda'), findsOneWidget);
  });
}
