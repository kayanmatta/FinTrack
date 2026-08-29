import 'package:drift/drift.dart';

/// Usuários do aplicativo (perfil local, sem sincronização).
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Contas financeiras (carteira, conta corrente, poupança, etc.).
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// 'carteira' | 'corrente' | 'poupanca' | 'credito'
  TextColumn get type => text().withDefault(const Constant('carteira'))();

  /// Saldo inicial em centavos.
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Categorias de movimentação (padrões e personalizadas).
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get icon => text()();
  TextColumn get color => text()();

  /// 'despesa' | 'receita'
  TextColumn get type => text().withDefault(const Constant('despesa'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

/// Receitas e despesas registradas pelo usuário.
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'receita' | 'despesa'
  TextColumn get type => text()();

  /// Valor em centavos (sempre positivo; o tipo define o sinal).
  IntColumn get amount => integer().withDefault(const Constant(0))();
  IntColumn get categoryId =>
      integer().references(Categories, #id).nullable()();
  IntColumn get accountId => integer().references(Accounts, #id).nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Metas de economia do usuário.
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// Valor alvo em centavos.
  IntColumn get targetAmount => integer().withDefault(const Constant(0))();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Aportes realizados em uma meta.
class GoalContributions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(Goals, #id)();

  /// Valor do aporte em centavos.
  IntColumn get amount => integer().withDefault(const Constant(0))();
  DateTimeColumn get date => dateTime()();
}

/// Orçamento mensal alocado por categoria.
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();

  /// Mês de referência no formato 'yyyy-MM'.
  TextColumn get month => text().withLength(min: 7, max: 7)();

  /// Limite alocado em centavos.
  IntColumn get limitAmount => integer().withDefault(const Constant(0))();
}

/// Renda mensal informada pelo usuário para o orçamento (S6-01).
class BudgetIncomes extends Table {
  /// Mês de referência no formato 'yyyy-MM'.
  TextColumn get month => text().withLength(min: 7, max: 7)();

  /// Renda total em centavos.
  IntColumn get amount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {month};
}
