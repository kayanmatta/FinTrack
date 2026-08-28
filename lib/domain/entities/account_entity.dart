/// Conta financeira do usuário (camada de domínio).
class AccountEntity {
  const AccountEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.color,
    required this.createdAt,
  });

  final int id;
  final String name;

  /// 'carteira' | 'corrente' | 'poupanca' | 'credito'
  final String type;

  /// Saldo inicial em centavos.
  final int initialBalance;

  /// Cor no formato '#RRGGBB'.
  final String color;
  final DateTime createdAt;

  AccountEntity copyWith({
    String? name,
    String? type,
    int? initialBalance,
    String? color,
  }) {
    return AccountEntity(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      color: color ?? this.color,
      createdAt: createdAt,
    );
  }
}
