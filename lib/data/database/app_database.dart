import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Banco de dados local do Centivo (offline-first).
///
/// Todas as informações permanecem exclusivamente no dispositivo do usuário.
@DriftDatabase(
  tables: [
    Users,
    Accounts,
    Categories,
    Transactions,
    Goals,
    GoalContributions,
    Budgets,
    BudgetIncomes,
    ReadAlerts,
    FixedExpenses,
    FixedExpensePayments,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// [executor] opcional: usado em testes para injetar um banco em memória.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(budgetIncomes);
          }
          if (from < 3) {
            await m.createTable(readAlerts);
          }
          if (from < 4) {
            // O v4 antigo (build não distribuído) adicionava a coluna
            // isFixed em transactions; ela foi substituída pelas tabelas
            // de fixos no v5. Bancos já no v4 mantêm a coluna órfã, que é
            // ignorada pelo código gerado.
          }
          if (from < 5) {
            await m.createTable(fixedExpenses);
            await m.createTable(fixedExpensePayments);
          }
        },
      );

  /// Garante que o banco foi criado e está pronto para uso.
  Future<void> ensureReady() async {
    await customSelect('SELECT 1').get();
  }
}

/// Cria o arquivo do banco no diretório de documentos do aplicativo.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'fintrack.db'));
    return NativeDatabase.createInBackground(file);
  });
}
