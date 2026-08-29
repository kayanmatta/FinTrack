import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/repositories/backup_repository.dart';
import '../database/app_database.dart';

/// Versão do formato do arquivo de backup (para compatibilidade futura).
const backupFormatVersion = 1;

/// Backup completo em JSON: exporta e restaura todas as tabelas do banco.
///
/// Os IDs originais são preservados na restauração, mantendo as relações
/// entre contas, categorias, transações, metas e orçamentos.
class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<String> exportBackup() async {
    final users = await _db.select(_db.users).get();
    final accounts = await _db.select(_db.accounts).get();
    final categories = await _db.select(_db.categories).get();
    final transactions = await _db.select(_db.transactions).get();
    final goals = await _db.select(_db.goals).get();
    final contributions = await _db.select(_db.goalContributions).get();
    final budgets = await _db.select(_db.budgets).get();
    final incomes = await _db.select(_db.budgetIncomes).get();

    final data = {
      'users': [
        for (final u in users)
          {'id': u.id, 'name': u.name, 'createdAt': u.createdAt.toIso8601String()},
      ],
      'accounts': [
        for (final a in accounts)
          {
            'id': a.id,
            'name': a.name,
            'type': a.type,
            'initialBalance': a.initialBalance,
            'color': a.color,
            'createdAt': a.createdAt.toIso8601String(),
          },
      ],
      'categories': [
        for (final c in categories)
          {
            'id': c.id,
            'name': c.name,
            'icon': c.icon,
            'color': c.color,
            'type': c.type,
            'isDefault': c.isDefault,
          },
      ],
      'transactions': [
        for (final t in transactions)
          {
            'id': t.id,
            'type': t.type,
            'amount': t.amount,
            'categoryId': t.categoryId,
            'accountId': t.accountId,
            'date': t.date.toIso8601String(),
            'description': t.description,
            'createdAt': t.createdAt.toIso8601String(),
          },
      ],
      'goals': [
        for (final g in goals)
          {
            'id': g.id,
            'name': g.name,
            'targetAmount': g.targetAmount,
            'deadline': g.deadline?.toIso8601String(),
            'icon': g.icon,
            'color': g.color,
            'createdAt': g.createdAt.toIso8601String(),
          },
      ],
      'goalContributions': [
        for (final c in contributions)
          {
            'id': c.id,
            'goalId': c.goalId,
            'amount': c.amount,
            'date': c.date.toIso8601String(),
          },
      ],
      'budgets': [
        for (final b in budgets)
          {
            'id': b.id,
            'categoryId': b.categoryId,
            'month': b.month,
            'limitAmount': b.limitAmount,
          },
      ],
      'budgetIncomes': [
        for (final i in incomes) {'month': i.month, 'amount': i.amount},
      ],
    };

    return const JsonEncoder.withIndent('  ').convert({
      'app': 'FinTrack',
      'format': backupFormatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  @override
  Future<void> importBackup(String content) async {
    final dynamic decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic> || decoded['app'] != 'FinTrack') {
      throw const FormatException('O arquivo não é um backup do FinTrack.');
    }
    final dynamic raw = decoded['data'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Backup sem dados.');
    }

    List<Map<String, dynamic>> rows(String table) =>
        ((raw[table] as List?) ?? const [])
            .map((row) => Map<String, dynamic>.from(row as Map))
            .toList();

    await _db.transaction(() async {
      // Exclui na ordem das FKs (filhos antes dos pais).
      await _db.delete(_db.goalContributions).go();
      await _db.delete(_db.budgets).go();
      await _db.delete(_db.budgetIncomes).go();
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.goals).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.accounts).go();
      await _db.delete(_db.users).go();

      await _db.batch((batch) {
        batch.insertAll(_db.users, [
          for (final u in rows('users'))
            UsersCompanion.insert(
              id: Value(u['id'] as int),
              name: u['name'] as String,
              createdAt: Value(_dateTime(u['createdAt'])),
            ),
        ]);
        batch.insertAll(_db.accounts, [
          for (final a in rows('accounts'))
            AccountsCompanion.insert(
              id: Value(a['id'] as int),
              name: a['name'] as String,
              type: Value(a['type'] as String),
              initialBalance: Value(a['initialBalance'] as int),
              color: Value(a['color'] as String?),
              createdAt: Value(_dateTime(a['createdAt'])),
            ),
        ]);
        batch.insertAll(_db.categories, [
          for (final c in rows('categories'))
            CategoriesCompanion.insert(
              id: Value(c['id'] as int),
              name: c['name'] as String,
              icon: c['icon'] as String,
              color: c['color'] as String,
              type: Value(c['type'] as String),
              isDefault: Value(c['isDefault'] as bool),
            ),
        ]);
        batch.insertAll(_db.transactions, [
          for (final t in rows('transactions'))
            TransactionsCompanion.insert(
              id: Value(t['id'] as int),
              type: t['type'] as String,
              amount: Value(t['amount'] as int),
              categoryId: Value(t['categoryId'] as int?),
              accountId: Value(t['accountId'] as int?),
              date: _dateTime(t['date']),
              description: Value(t['description'] as String?),
              createdAt: Value(_dateTime(t['createdAt'])),
            ),
        ]);
        batch.insertAll(_db.goals, [
          for (final g in rows('goals'))
            GoalsCompanion.insert(
              id: Value(g['id'] as int),
              name: g['name'] as String,
              targetAmount: Value(g['targetAmount'] as int),
              deadline: Value(
                g['deadline'] == null ? null : _dateTime(g['deadline']),
              ),
              icon: Value(g['icon'] as String?),
              color: Value(g['color'] as String?),
              createdAt: Value(_dateTime(g['createdAt'])),
            ),
        ]);
        batch.insertAll(_db.goalContributions, [
          for (final c in rows('goalContributions'))
            GoalContributionsCompanion.insert(
              id: Value(c['id'] as int),
              goalId: c['goalId'] as int,
              amount: Value(c['amount'] as int),
              date: _dateTime(c['date']),
            ),
        ]);
        batch.insertAll(_db.budgets, [
          for (final b in rows('budgets'))
            BudgetsCompanion.insert(
              id: Value(b['id'] as int),
              categoryId: b['categoryId'] as int,
              month: b['month'] as String,
              limitAmount: Value(b['limitAmount'] as int),
            ),
        ]);
        batch.insertAll(_db.budgetIncomes, [
          for (final i in rows('budgetIncomes'))
            BudgetIncomesCompanion.insert(
              month: i['month'] as String,
              amount: Value(i['amount'] as int),
            ),
        ]);
      });
    });
  }

  DateTime _dateTime(Object? value) => DateTime.parse(value! as String);
}
