import 'package:intl/intl.dart';

/// Formatação e conversão de valores monetários.
///
/// No banco os valores são sempre inteiros em centavos;
/// aqui fica a conversão de/para exibição 'R$ 1.234,56'.
final _brl = NumberFormat.currency(
  symbol: 'R\$',
  locale: 'pt_BR',
  decimalDigits: 2,
);

/// Formata centavos como moeda brasileira.
///
/// O intl usa espaço não-separável (U+00A0) entre símbolo e valor;
/// normalizamos para espaço comum para exibição consistente.
String formatCents(int cents) =>
    _brl.format(cents / 100).replaceAll('\u00A0', ' ');

/// Converte um texto monetário ('1.234,56' ou '10.50') em centavos.
int parseCents(String text) {
  final cleaned = text.trim().replaceFirst('R\$', '').trim();
  if (cleaned.isEmpty) return 0;
  final double? value;
  if (cleaned.contains(',')) {
    value = double.tryParse(
      cleaned.replaceAll('.', '').replaceAll(',', '.'),
    );
  } else {
    value = double.tryParse(cleaned);
  }
  if (value == null) return 0;
  return (value * 100).round();
}
