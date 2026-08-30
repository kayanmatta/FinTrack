/// Receita ou despesa registrada pelo usuário (camada de domínio).
class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.date,
    required this.description,
    required this.createdAt,
  });

  final int id;

  /// 'receita' | 'despesa'
  final String type;

  /// Valor em centavos (sempre positivo; o tipo define o sinal).
  final int amount;

  /// Categoria vinculada (nula quando a categoria foi excluída).
  final int? categoryId;

  /// Conta vinculada (nula quando a conta foi excluída).
  final int? accountId;
  final DateTime date;
  final String? description;
  final DateTime createdAt;

  bool get isIncome => type == 'receita';

  TransactionEntity copyWith({
    String? type,
    int? amount,
    int? Function()? categoryId,
    int? Function()? accountId,
    DateTime? date,
    String? Function()? description,
  }) {
    return TransactionEntity(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      accountId: accountId != null ? accountId() : this.accountId,
      date: date ?? this.date,
      description: description != null ? description() : this.description,
      createdAt: createdAt,
    );
  }
}
