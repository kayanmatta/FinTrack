import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/data/database/app_database.dart';
import 'package:fintrack/data/repositories/goal_repository_impl.dart';

void main() {
  late AppDatabase db;
  late GoalRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = GoalRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('Cria meta e lista da mais recente para a mais antiga', () async {
    await repository.create(
      name: 'Viagem',
      targetAmount: 500000,
      deadline: DateTime(2027, 12, 31),
      icon: 'flight',
      color: '#3B82F6',
    );
    // createdAt padrão é o instante atual; garante ordem com um pequeno atraso.
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final segundo = await repository.create(
      name: 'Reserva',
      targetAmount: 1000000,
    );

    final goals = await repository.watchAll().first;
    expect(goals, hasLength(2));
    expect(goals.first.name, 'Reserva');
    expect(goals.first.targetAmount, 1000000);
    expect(goals.last.name, 'Viagem');
    expect(goals.last.deadline, DateTime(2027, 12, 31));
    expect(goals.last.icon, 'flight');
    expect(segundo, greaterThan(goals.last.id!));
  });

  test('Registra aportes e lista por meta, do mais recente primeiro',
      () async {
    final goalId = await repository.create(
      name: 'Notebook',
      targetAmount: 400000,
    );
    final outraMetaId = await repository.create(
      name: 'Outra',
      targetAmount: 100000,
    );

    await repository.addContribution(
      goalId: goalId,
      amount: 100000,
      date: DateTime(2026, 7, 10),
    );
    await repository.addContribution(
      goalId: goalId,
      amount: 150000,
      date: DateTime(2026, 8, 10),
    );
    await repository.addContribution(
      goalId: outraMetaId,
      amount: 50000,
      date: DateTime(2026, 8, 15),
    );

    final contributions = await repository.watchContributions(goalId).first;
    expect(contributions, hasLength(2));
    expect(contributions.first.amount, 150000);
    expect(contributions.last.amount, 100000);
  });

  test('Excluir meta remove também os aportes (S7-06)', () async {
    final goalId = await repository.create(
      name: 'Viagem',
      targetAmount: 500000,
    );
    await repository.addContribution(
      goalId: goalId,
      amount: 100000,
      date: DateTime(2026, 8, 10),
    );

    await repository.delete(goalId);

    expect(await repository.watchAll().first, isEmpty);
    expect(await repository.watchContributions(goalId).first, isEmpty);
  });
}
