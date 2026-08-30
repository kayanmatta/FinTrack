import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/utils/alert_builder.dart';
import 'package:fintrack/domain/entities/alert_entity.dart';
import 'package:fintrack/domain/entities/budget_entity.dart';
import 'package:fintrack/domain/entities/goal_entity.dart';
import 'package:fintrack/domain/entities/transaction_entity.dart';

int _nextId = 0;

TransactionEntity _tx(String type, int amount, DateTime date, {int? categoryId}) {
  return TransactionEntity(
    id: _nextId++,
    type: type,
    amount: amount,
    categoryId: categoryId,
    accountId: null,
    date: date,
    description: null,
    createdAt: date,
  );
}

void main() {
  final now = DateTime(2026, 8, 15);
  final previous = DateTime(2026, 7, 15);
  const categories = {1: 'Mercado'};

  group('buildAlerts', () {
    test('Sem dados não há alertas', () {
      expect(
        buildAlerts(
          transactions: const [],
          budgets: const [],
          goals: const [],
          contributedByGoal: const {},
          categoryNames: const {},
          now: now,
        ),
        isEmpty,
      );
    });

    test('Variação acima de 25% gera alerta (S8-02)', () {
      final alerts = buildAlerts(
        transactions: [
          _tx('despesa', 100000, previous, categoryId: 1),
          _tx('despesa', 150000, now, categoryId: 1),
        ],
        budgets: const [],
        goals: const [],
        contributedByGoal: const {},
        categoryNames: categories,
        now: now,
      );
      final alert = alerts.singleWhere((a) => a.key == 'variacao-1-2026-08');
      expect(alert.severity, AlertSeverity.warning);
      expect(alert.message, contains('50,0% a mais em Mercado'));
    });

    test('Variação abaixo do limiar não gera alerta', () {
      final alerts = buildAlerts(
        transactions: [
          _tx('despesa', 100000, previous, categoryId: 1),
          _tx('despesa', 110000, now, categoryId: 1),
        ],
        budgets: const [],
        goals: const [],
        contributedByGoal: const {},
        categoryNames: categories,
        now: now,
      );
      expect(alerts.where((a) => a.key.startsWith('variacao')), isEmpty);
    });

    test('Orçamento aos 80% avisa e acima de 100% estoura (S8-03)', () {
      final budgets = [
        const BudgetEntity(id: 1, categoryId: 1, month: '2026-08', limitAmount: 100000),
      ];
      final aos80 = buildAlerts(
        transactions: [_tx('despesa', 80000, now, categoryId: 1)],
        budgets: budgets,
        goals: const [],
        contributedByGoal: const {},
        categoryNames: categories,
        now: now,
      );
      final aviso = aos80.singleWhere((a) => a.key == 'orcamento-1-2026-08');
      expect(aviso.severity, AlertSeverity.warning);
      expect(aviso.message, contains('80,0% do limite de Mercado'));

      final estourado = buildAlerts(
        transactions: [_tx('despesa', 120000, now, categoryId: 1)],
        budgets: budgets,
        goals: const [],
        contributedByGoal: const {},
        categoryNames: categories,
        now: now,
      );
      final estouro = estourado.singleWhere((a) => a.key == 'orcamento-1-2026-08');
      expect(estouro.severity, AlertSeverity.danger);
      expect(estouro.message, contains('ultrapassou o limite de Mercado'));
    });

    test('Meta incompleta alerta quanto falta (S8-04)', () {
      final alerts = buildAlerts(
        transactions: const [],
        budgets: const [],
        goals: [
          GoalEntity(
            id: 7,
            name: 'Viagem',
            targetAmount: 100000,
            createdAt: now,
          ),
        ],
        contributedByGoal: {7: 40000},
        categoryNames: const {},
        now: now,
      );
      final alert = alerts.singleWhere((a) => a.key == 'meta-7');
      expect(alert.severity, AlertSeverity.info);
      expect(alert.message, 'Faltam R\$ 600,00 para atingir a meta Viagem.');
    });

    test('Meta concluída não gera alerta', () {
      final alerts = buildAlerts(
        transactions: const [],
        budgets: const [],
        goals: [
          GoalEntity(id: 7, name: 'Viagem', targetAmount: 100000, createdAt: now),
        ],
        contributedByGoal: {7: 100000},
        categoryNames: const {},
        now: now,
      );
      expect(alerts.where((a) => a.key.startsWith('meta')), isEmpty);
    });

    test('Economia do mês com mensagem por limiar (S8-05)', () {
      AlertEntity economia(List<TransactionEntity> transactions) {
        return buildAlerts(
          transactions: transactions,
          budgets: const [],
          goals: const [],
          contributedByGoal: const {},
          categoryNames: const {},
          now: now,
        ).singleWhere((a) => a.key == 'economia-2026-08');
      }

      // Economia de 50%: mensagem positiva.
      final alta = economia([
        _tx('receita', 100000, now),
        _tx('despesa', 50000, now),
      ]);
      expect(alta.severity, AlertSeverity.positive);
      expect(alta.message, contains('economia do mês é de 50,0%'));

      // Gastou mais do que recebeu: severidade máxima.
      final negativa = economia([
        _tx('receita', 100000, now),
        _tx('despesa', 120000, now),
      ]);
      expect(negativa.severity, AlertSeverity.danger);
      expect(negativa.message, contains('gastou mais do que recebeu'));
    });

    test('Ordena da maior para a menor severidade', () {
      final alerts = buildAlerts(
        transactions: [
          _tx('receita', 200000, now),
          _tx('despesa', 120000, now, categoryId: 1),
          _tx('despesa', 90000, previous, categoryId: 1),
        ],
        budgets: [
          const BudgetEntity(id: 1, categoryId: 1, month: '2026-08', limitAmount: 50000),
        ],
        goals: [
          GoalEntity(id: 7, name: 'Viagem', targetAmount: 100000, createdAt: now),
        ],
        contributedByGoal: const {},
        categoryNames: categories,
        now: now,
      );
      expect(alerts.first.severity, AlertSeverity.danger);
      expect(alerts.last.severity, AlertSeverity.positive);
    });
  });
}
