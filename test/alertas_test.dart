import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/utils/budget_metrics.dart';
import 'package:fintrack/data/database/app_database.dart';
import 'package:fintrack/data/repositories/alert_repository_impl.dart';

DateTime _thisMonth(int day) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, day);
}

DateTime _lastMonth(int day) {
  final now = DateTime.now();
  return DateTime(now.year, now.month - 1, day);
}

void main() {
  late AppDatabase db;
  late AlertRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = AlertRepositoryImpl(db);
  });

  tearDown(() => db.close());

  Future<int> seedMercado() {
    return db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: 'Mercado',
            icon: 'shopping_cart',
            color: '#10B981',
          ),
        );
  }

  Future<void> seedTx(String type, int amount, DateTime date, int categoryId) {
    return db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            type: type,
            amount: Value(amount),
            categoryId: Value(categoryId),
            date: date,
          ),
        );
  }

  test('Deriva alertas de orçamento, variação, meta e economia (S8-02..05)',
      () async {
    final mercado = await seedMercado();
    // Variação de +100% em Mercado e estouro do limite de R$ 1.000.
    await seedTx('despesa', 100000, _lastMonth(5), mercado);
    await seedTx('despesa', 200000, _thisMonth(5), mercado);
    // Receita do mês gera alerta de economia (80% de taxa).
    await seedTx('receita', 1000000, _thisMonth(5), mercado);

    await db.into(db.budgets).insert(
          BudgetsCompanion.insert(
            categoryId: mercado,
            month: monthKey(DateTime.now()),
            limitAmount: Value(100000),
          ),
        );

    final viagem = await db.into(db.goals).insert(
          GoalsCompanion.insert(name: 'Viagem', targetAmount: Value(100000)),
        );
    await db.into(db.goalContributions).insert(
          GoalContributionsCompanion.insert(
            goalId: viagem,
            amount: Value(40000),
            date: _thisMonth(10),
          ),
        );

    final pending = await repository.watchPending().first;
    final keys = {for (final alert in pending) alert.key};
    expect(
      keys,
      {
        'orcamento-$mercado-${monthKey(DateTime.now())}',
        'variacao-$mercado-${monthKey(DateTime.now())}',
        'meta-$viagem',
        'economia-${monthKey(DateTime.now())}',
      },
    );
  });

  test('Marcar como lido remove o alerta da lista de pendentes', () async {
    final mercado = await seedMercado();
    await seedTx('despesa', 100000, _lastMonth(5), mercado);
    await seedTx('despesa', 200000, _thisMonth(5), mercado);

    final pending = await repository.watchPending().first;
    expect(pending, isNotEmpty);

    await repository.markRead([for (final alert in pending) alert.key]);

    expect(await repository.watchPending().first, isEmpty);
  });
}
