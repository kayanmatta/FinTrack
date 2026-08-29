import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/data/database/app_database.dart';
import 'package:fintrack/data/repositories/backup_repository_impl.dart';
import 'package:fintrack/data/repositories/budget_repository_impl.dart';
import 'package:fintrack/data/repositories/category_repository_impl.dart';
import 'package:fintrack/data/repositories/transaction_repository_impl.dart';

/// Popula o banco com dados de todas as tabelas.
Future<void> _seed(AppDatabase db) async {
  await db.into(db.users).insert(UsersCompanion.insert(name: 'Kayan'));
  await db.into(db.accounts).insert(
        AccountsCompanion.insert(
          name: 'Carteira',
          type: const Value('carteira'),
          initialBalance: const Value(10000),
          color: const Value('#22C55E'),
        ),
      );
  final categories = CategoryRepositoryImpl(db);
  final categoryId = await categories.create(
    name: 'Mercado',
    icon: 'shopping_cart',
    color: '#EF4444',
    type: 'despesa',
  );
  await TransactionRepositoryImpl(db).create(
    type: 'despesa',
    amount: 4550,
    categoryId: categoryId,
    accountId: 1,
    date: DateTime(2026, 8, 25),
    description: 'Compra da semana',
  );
  await db.into(db.goals).insert(
        GoalsCompanion.insert(
          name: 'Reserva de emergência',
          targetAmount: const Value(1000000),
          deadline: Value(DateTime(2026, 12, 31)),
          icon: const Value('savings'),
          color: const Value('#3B82F6'),
        ),
      );
  await db.into(db.goalContributions).insert(
        GoalContributionsCompanion.insert(
          goalId: 1,
          amount: const Value(250000),
          date: DateTime(2026, 8, 1),
        ),
      );
  await BudgetRepositoryImpl(db).save(
    month: '2026-08',
    income: 400000,
    allocations: {categoryId: 150000},
  );
}

void main() {
  test('Exporta todos os dados em JSON com a estrutura do backup', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _seed(db);

    final json = await BackupRepositoryImpl(db).exportBackup();
    final decoded = jsonDecode(json) as Map<String, dynamic>;

    expect(decoded['app'], 'FinTrack');
    expect(decoded['format'], backupFormatVersion);
    final data = decoded['data'] as Map<String, dynamic>;
    expect((data['users'] as List), hasLength(1));
    expect((data['accounts'] as List), hasLength(1));
    expect((data['categories'] as List), hasLength(1));
    expect((data['transactions'] as List), hasLength(1));
    expect((data['goals'] as List), hasLength(1));
    expect((data['goalContributions'] as List), hasLength(1));
    expect((data['budgets'] as List), hasLength(1));
    expect((data['budgetIncomes'] as List), hasLength(1));
  });

  test('Restaura o backup em outro banco preservando IDs e relações',
      () async {
    final source = AppDatabase(NativeDatabase.memory());
    final target = AppDatabase(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(target.close);
    await _seed(source);

    final json = await BackupRepositoryImpl(source).exportBackup();
    await BackupRepositoryImpl(target).importBackup(json);

    expect((await target.select(target.users).get()).single.name, 'Kayan');
    final account = (await target.select(target.accounts).get()).single;
    expect(account.id, 1);
    expect(account.initialBalance, 10000);
    final category = (await target.select(target.categories).get()).single;
    expect(category.id, 1);
    expect(category.name, 'Mercado');
    final transaction = (await target.select(target.transactions).get()).single;
    expect(transaction.categoryId, category.id);
    expect(transaction.accountId, account.id);
    expect(transaction.description, 'Compra da semana');
    final goal = (await target.select(target.goals).get()).single;
    expect(goal.targetAmount, 1000000);
    expect(goal.deadline, DateTime(2026, 12, 31));
    final contribution =
        (await target.select(target.goalContributions).get()).single;
    expect(contribution.goalId, goal.id);
    expect(contribution.amount, 250000);
    final budget = (await target.select(target.budgets).get()).single;
    expect(budget.categoryId, category.id);
    expect(budget.limitAmount, 150000);
    final income = (await target.select(target.budgetIncomes).get()).single;
    expect(income.month, '2026-08');
    expect(income.amount, 400000);
  });

  test('Restaurar substitui os dados existentes do banco de destino',
      () async {
    final source = AppDatabase(NativeDatabase.memory());
    final target = AppDatabase(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(target.close);
    await _seed(source);
    // Destino tem dados próprios que devem ser apagados.
    await CategoryRepositoryImpl(target).create(
      name: 'Antiga',
      icon: 'label',
      color: '#000000',
      type: 'despesa',
    );

    final json = await BackupRepositoryImpl(source).exportBackup();
    await BackupRepositoryImpl(target).importBackup(json);

    final categories = await target.select(target.categories).get();
    expect(categories, hasLength(1));
    expect(categories.single.name, 'Mercado');
  });

  test('Rejeita arquivos que não são backup do FinTrack', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BackupRepositoryImpl(db);

    await expectLater(
      repository.importBackup('{"app":"OutroApp","data":{}}'),
      throwsFormatException,
    );
    await expectLater(
      repository.importBackup('{"app":"FinTrack"}'),
      throwsFormatException,
    );
  });
}
