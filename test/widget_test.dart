import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fintrack/domain/entities/account_entity.dart';
import 'package:fintrack/domain/entities/category_entity.dart';
import 'package:fintrack/domain/entities/transaction_entity.dart';
import 'package:fintrack/domain/repositories/account_repository.dart';
import 'package:fintrack/domain/repositories/category_repository.dart';
import 'package:fintrack/domain/repositories/transaction_repository.dart';
import 'package:fintrack/main.dart';
import 'package:fintrack/presentation/providers/account_provider.dart';
import 'package:fintrack/presentation/providers/category_provider.dart';
import 'package:fintrack/presentation/providers/startup_provider.dart';
import 'package:fintrack/presentation/providers/transaction_provider.dart';

/// Repositórios vazios para o fluxo de login não tocar o banco real.
class _NoopTransactionRepository implements TransactionRepository {
  @override
  Stream<List<TransactionEntity>> watchAll() => Stream.value([]);

  @override
  Future<int> create({
    required String type,
    required int amount,
    int? categoryId,
    int? accountId,
    required DateTime date,
    String? description,
  }) async =>
      0;

  @override
  Future<void> update(TransactionEntity transaction) async {}

  @override
  Future<void> delete(int id) async {}
}

class _NoopCategoryRepository implements CategoryRepository {
  @override
  Stream<List<CategoryEntity>> watchAll() => Stream.value([]);

  @override
  Future<int> create({
    required String name,
    required String icon,
    required String color,
    required String type,
  }) async =>
      0;

  @override
  Future<void> update(CategoryEntity category) async {}

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> ensureDefaultCategories() async {}
}

class _NoopAccountRepository implements AccountRepository {
  @override
  Stream<List<AccountEntity>> watchAll() => Stream.value([]);

  @override
  Future<int> create({
    required String name,
    required String type,
    required int initialBalance,
    required String color,
  }) async =>
      0;

  @override
  Future<void> update(AccountEntity account) async {}

  @override
  Future<void> delete(int id) async {}
}

/// Simula um dispositivo sem biometria para o plugin local_auth.
void _mockLocalAuthChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/local_auth'),
    (call) async {
      switch (call.method) {
        case 'getAvailableBiometrics':
          return <String>[];
        case 'isDeviceSupported':
        case 'authenticate':
        case 'stopAuthentication':
          return false;
        default:
          return null;
      }
    },
  );
}

Future<void> _typePin(WidgetTester tester, List<String> digits) async {
  for (final digit in digits) {
    await tester.tap(find.text(digit));
    await tester.pump();
  }
}

/// Aguarda o carregamento inicial da tela de login sem travar
/// no spinner de loading (animação infinita).
Future<void> _awaitLoginReady(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('Primeiro acesso cria PIN e desbloqueia o app', (tester) async {
    SharedPreferences.setMockInitialValues({});
    _mockLocalAuthChannel();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupProvider.overrideWith((ref) async {}),
          transactionRepositoryProvider
              .overrideWithValue(_NoopTransactionRepository()),
          categoryRepositoryProvider.overrideWithValue(_NoopCategoryRepository()),
          accountRepositoryProvider.overrideWithValue(_NoopAccountRepository()),
        ],
        child: const FinTrackApp(),
      ),
    );
    await _awaitLoginReady(tester);
    expect(find.text('Criar PIN'), findsOneWidget);

    await _typePin(tester, ['1', '2', '3', '4']);
    expect(find.text('Confirmar PIN'), findsOneWidget);

    await _typePin(tester, ['1', '2', '3', '4']);
    await tester.pump();
    // Rótulo na barra lateral + título do cabeçalho do dashboard.
    expect(find.text('Dashboard'), findsNWidgets(2));
  });

  testWidgets('Navega para a tela de metas após desbloquear', (tester) async {
    SharedPreferences.setMockInitialValues({});
    _mockLocalAuthChannel();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupProvider.overrideWith((ref) async {}),
          transactionRepositoryProvider
              .overrideWithValue(_NoopTransactionRepository()),
          categoryRepositoryProvider.overrideWithValue(_NoopCategoryRepository()),
          accountRepositoryProvider.overrideWithValue(_NoopAccountRepository()),
        ],
        child: const FinTrackApp(),
      ),
    );
    await _awaitLoginReady(tester);
    await _typePin(tester, ['1', '2', '3', '4']);
    await _typePin(tester, ['1', '2', '3', '4']);
    await tester.pump();

    // IndexedStack constrói apenas a tela exibida: 'Metas' aparece na
    // barra lateral e, após o toque, também no AppBar da tela.
    await tester.tap(find.text('Metas').first);
    await tester.pump();
    expect(find.text('Metas'), findsNWidgets(2));
  });
}
