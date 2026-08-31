/// Lançamento fixo cadastrado pelo usuário (S9).
///
/// Fica pendente a cada mês e só vira movimentação real quando o usuário
/// confirma o pagamento. Enquanto isso não entra no saldo nem no extrato.
class FixedExpenseEntity {
  const FixedExpenseEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.day,
    required this.createdAt,
    this.categoryId,
    this.accountId,
    this.description,
  });

  /// Id no banco local.
  final int id;

  /// 'receita' | 'despesa'
  final String type;

  /// Valor em centavos.
  final int amount;
  final int? categoryId;
  final int? accountId;
  final String? description;

  /// Dia de vencimento (1-31; meses menores usam o último dia).
  final int day;

  /// Data de criação do lançamento fixo.
  final DateTime createdAt;

  /// True para lançamentos de receita.
  bool get isIncome => type == 'receita';

  FixedExpenseEntity copyWith({
    int? id,
    String? type,
    int? amount,
    int? categoryId,
    int? accountId,
    String? description,
    int? day,
    DateTime? createdAt,
  }) {
    return FixedExpenseEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      description: description ?? this.description,
      day: day ?? this.day,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Pagamento confirmado de um lançamento fixo em um mês (S9).
class FixedExpensePaymentEntity {
  const FixedExpensePaymentEntity({
    required this.id,
    required this.fixedId,
    required this.month,
    required this.paidAt,
    this.transactionId,
  });

  final int id;
  final int fixedId;

  /// Mês de referência no formato 'yyyy-MM'.
  final String month;

  /// Transação real criada ao confirmar o pagamento.
  final int? transactionId;
  final DateTime paidAt;
}
