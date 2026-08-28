import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Paleta de cores disponíveis para categorias e contas.
const List<Color> presetColors = [
  AppColors.primary,
  AppColors.primaryLight,
  AppColors.income,
  AppColors.expense,
  AppColors.info,
  AppColors.warning,
  Color(0xFFEC4899), // rosa
  Color(0xFF14B8A6), // verde-água
  Color(0xFF8B5CF6), // violeta
  Color(0xFF64748B), // cinza
];

/// Converte '#RRGGBB' em [Color], com fallback seguro.
Color colorFromHex(String? hex, {Color fallback = AppColors.primary}) {
  if (hex == null) return fallback;
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  if (value == null) return fallback;
  return Color(0xFF000000 | value);
}

/// Converte [Color] no formato '#RRGGBB' usado no banco.
String colorToHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
