import 'package:flutter/material.dart';

/// Ícones disponíveis para categorias.
///
/// O nome (chave) é o valor salvo no banco; o [IconData] é a
/// representação visual correspondente.
const Map<String, IconData> categoryIcons = {
  'shopping_cart': Icons.shopping_cart,
  'directions_car': Icons.directions_car,
  'sports_esports': Icons.sports_esports,
  'favorite': Icons.favorite,
  'home': Icons.home,
  'menu_book': Icons.menu_book,
  'shopping_bag': Icons.shopping_bag,
  'restaurant': Icons.restaurant,
  'flight': Icons.flight,
  'pets': Icons.pets,
  'music_note': Icons.music_note,
  'more_horiz': Icons.more_horiz,
};

/// Resolve o ícone pelo nome salvo, com fallback seguro.
IconData iconFromName(String? name) {
  if (name != null && categoryIcons.containsKey(name)) {
    return categoryIcons[name]!;
  }
  return Icons.label_outline;
}
