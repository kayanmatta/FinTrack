import 'package:flutter/material.dart';

/// Rótulos de exibição dos tipos de conta.
const Map<String, String> accountTypeLabels = {
  'carteira': 'Carteira',
  'corrente': 'Conta corrente',
  'poupanca': 'Poupança',
  'credito': 'Cartão de crédito',
};

/// Ícones dos tipos de conta.
const Map<String, IconData> accountTypeIcons = {
  'carteira': Icons.account_balance_wallet,
  'corrente': Icons.account_balance,
  'poupanca': Icons.savings,
  'credito': Icons.credit_card,
};

/// Rótulo de exibição do tipo, com fallback seguro.
String accountTypeLabel(String type) => accountTypeLabels[type] ?? type;

/// Ícone do tipo, com fallback seguro.
IconData accountTypeIcon(String type) =>
    accountTypeIcons[type] ?? Icons.account_balance_wallet;
