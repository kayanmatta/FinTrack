import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/utils/goal_metrics.dart';
import 'package:fintrack/domain/entities/goal_entity.dart';

GoalContributionEntity _contribution(int id, int amount, DateTime date) =>
    GoalContributionEntity(id: id, goalId: 1, amount: amount, date: date);

void main() {
  group('totalContributed', () {
    test('Soma os aportes da meta', () {
      final contributions = [
        _contribution(1, 100000, DateTime(2026, 6, 5)),
        _contribution(2, 50000, DateTime(2026, 7, 5)),
      ];
      expect(totalContributed(contributions), 150000);
    });

    test('Sem aportes o total é zero', () {
      expect(totalContributed(const []), 0);
    });
  });

  group('progressPercent', () {
    test('Percentual do aportado sobre o alvo', () {
      expect(
        progressPercent(targetAmount: 200000, contributed: 80000),
        40.0,
      );
    });

    test('Pode passar de 100%', () {
      expect(
        progressPercent(targetAmount: 100000, contributed: 120000),
        120.0,
      );
    });

    test('Alvo zero ou negativo retorna zero', () {
      expect(progressPercent(targetAmount: 0, contributed: 5000), 0);
    });
  });

  group('isGoalCompleted', () {
    test('Concluída quando o aportado alcança o alvo (S7-05)', () {
      expect(
        isGoalCompleted(targetAmount: 100000, contributed: 100000),
        isTrue,
      );
      expect(
        isGoalCompleted(targetAmount: 100000, contributed: 120000),
        isTrue,
      );
      expect(
        isGoalCompleted(targetAmount: 100000, contributed: 99999),
        isFalse,
      );
      expect(isGoalCompleted(targetAmount: 0, contributed: 0), isFalse);
    });
  });

  group('remainingAmount', () {
    test('Quanto falta para concluir, nunca negativo', () {
      expect(
        remainingAmount(targetAmount: 100000, contributed: 30000),
        70000,
      );
      expect(
        remainingAmount(targetAmount: 100000, contributed: 120000),
        0,
      );
    });
  });

  group('projectedCompletion', () {
    final now = DateTime(2026, 8, 15);

    test('Sem aportes ou meta concluída não há previsão', () {
      expect(
        projectedCompletion(targetAmount: 100000, contributions: [], now: now),
        isNull,
      );
      expect(
        projectedCompletion(
          targetAmount: 100000,
          contributions: [_contribution(1, 100000, DateTime(2026, 8, 1))],
          now: now,
        ),
        isNull,
      );
    });

    test('Aporte único no mês atual projeta pela média mensal', () {
      // 50000 aportados; faltam 50000; média 50000/mês → 1 mês.
      final projection = projectedCompletion(
        targetAmount: 100000,
        contributions: [_contribution(1, 50000, DateTime(2026, 8, 1))],
        now: now,
      );
      expect(projection, DateTime(2026, 9, 15));
    });

    test('Média considera os meses desde o primeiro aporte', () {
      // 3 meses de aportes de 10000 (média 10000/mês); faltam 30000 → 3 meses.
      final projection = projectedCompletion(
        targetAmount: 60000,
        contributions: [
          _contribution(1, 10000, DateTime(2026, 6, 5)),
          _contribution(2, 10000, DateTime(2026, 7, 5)),
          _contribution(3, 10000, DateTime(2026, 8, 5)),
        ],
        now: now,
      );
      expect(projection, DateTime(2026, 11, 15));
    });
  });
}
