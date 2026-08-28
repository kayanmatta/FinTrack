import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/domain/entities/account_entity.dart';
import 'package:fintrack/domain/repositories/account_repository.dart';
import 'package:fintrack/presentation/providers/account_provider.dart';
import 'package:fintrack/presentation/screens/accounts_screen.dart';

/// Repositório fake em memória para os testes de UI.
class FakeAccountRepository implements AccountRepository {
  FakeAccountRepository(List<AccountEntity> seed) : _items = List.of(seed);

  final List<AccountEntity> _items;
  final _controller = StreamController<List<AccountEntity>>.broadcast();
  int _nextId = 100;

  void _emit() => _controller.add(List.of(_items));

  @override
  Stream<List<AccountEntity>> watchAll() async* {
    yield List.of(_items);
    yield* _controller.stream;
  }

  @override
  Future<int> create({
    required String name,
    required String type,
    required int initialBalance,
    required String color,
  }) async {
    final id = _nextId++;
    _items.add(
      AccountEntity(
        id: id,
        name: name,
        type: type,
        initialBalance: initialBalance,
        color: color,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    _emit();
    return id;
  }

  @override
  Future<void> update(AccountEntity account) async {
    final index = _items.indexWhere((item) => item.id == account.id);
    if (index >= 0) _items[index] = account;
    _emit();
  }

  @override
  Future<void> delete(int id) async {
    _items.removeWhere((item) => item.id == id);
    _emit();
  }
}

void main() {
  testWidgets('Lista contas e cria nova conta', (tester) async {
    final repository = FakeAccountRepository([
      AccountEntity(
        id: 1,
        name: 'Carteira',
        type: 'carteira',
        initialBalance: 5000,
        color: '#6C2BD9',
        createdAt: DateTime(2026, 1, 1),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [accountRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const AccountsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Carteira'), findsOneWidget);

    // Cria uma nova conta pelo diálogo.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Reserva');
    await tester.tap(find.text('Poupança'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, '100,00');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Reserva'), findsOneWidget);
    expect(find.textContaining('R\$ 100,00'), findsOneWidget);
  });
}
