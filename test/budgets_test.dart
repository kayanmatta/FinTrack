import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/data/database/app_database.dart';
import 'package:fintrack/data/repositories/budget_repository_impl.dart';
import 'package:fintrack/data/repositories/category_repository_impl.dart';

void main() {
  late AppDatabase db;
  late BudgetRepositoryImpl repository;
  late int moradiaId;
  late int transporteId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = BudgetRepositoryImpl(db);
    // Categorias de apoio para as FKs dos orçamentos.
    final categories = CategoryRepositoryImpl(db);
    moradiaId = await categories.create(
      name: 'Moradia',
      icon: 'home',
      color: '#9F67FF',
      type: 'despesa',
    );
    transporteId = await categories.create(
      name: 'Transporte',
      icon: 'directions_car',
      color: '#3B82F6',
      type: 'despesa',
    );
  });

  tearDown(() => db.close());

  test('Salva renda e alocações e observa o mês', () async {
    await repository.save(
      month: '2026-08',
      income: 400000,
      allocations: {moradiaId: 150000, transporteId: 50000},
    );

    expect(await repository.watchIncome('2026-08').first, 400000);
    final budgets = await repository.watchMonth('2026-08').first;
    expect(budgets, hasLength(2));
    final byCategory = {for (final b in budgets) b.categoryId: b.limitAmount};
    expect(byCategory[moradiaId], 150000);
    expect(byCategory[transporteId], 50000);

    // Mês sem orçamento: renda nula e lista vazia.
    expect(await repository.watchIncome('2026-07').first, isNull);
    expect(await repository.watchMonth('2026-07').first, isEmpty);
  });

  test('Salvar novamente substitui o orçamento do mês', () async {
    await repository.save(
      month: '2026-08',
      income: 400000,
      allocations: {moradiaId: 150000, transporteId: 50000},
    );
    await repository.save(
      month: '2026-08',
      income: 500000,
      // Alocação zero não deve gerar linha no banco.
      allocations: {moradiaId: 200000, transporteId: 0},
    );

    expect(await repository.watchIncome('2026-08').first, 500000);
    final budgets = await repository.watchMonth('2026-08').first;
    expect(budgets, hasLength(1));
    expect(budgets.single.categoryId, moradiaId);
    expect(budgets.single.limitAmount, 200000);
  });

  test('Copia orçamento e renda do mês anterior (S6-06)', () async {
    await repository.save(
      month: '2026-07',
      income: 300000,
      allocations: {moradiaId: 90000},
    );

    await repository.copyMonth('2026-07', '2026-08');

    expect(await repository.watchIncome('2026-08').first, 300000);
    final budgets = await repository.watchMonth('2026-08').first;
    expect(budgets, hasLength(1));
    expect(budgets.single.categoryId, moradiaId);
    expect(budgets.single.limitAmount, 90000);
  });

  test('Copiar mês sem origem não cria nada no destino', () async {
    await repository.copyMonth('2026-06', '2026-08');
    expect(await repository.watchIncome('2026-08').first, isNull);
    expect(await repository.watchMonth('2026-08').first, isEmpty);
  });
}
