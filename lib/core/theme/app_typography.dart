import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de texto padrão do Centivo.
/// Usar em vez de TextStyle direto em cada tela.
class AppTypography {
  AppTypography._();

  // --- Títulos ---
  /// Títulos de tela: "Dashboard", "Análises"
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Títulos de seção: "Gastos por categoria", "Metas"
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Subtítulos
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // --- Corpo de texto ---
  /// Texto grande (parágrafos destacados)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Texto padrão (descrições, listas)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Texto pequeno (timestamps, "vs mês anterior")
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // --- Valores monetários ---
  /// Valor grande: "R$ 3.450,00" (saldo principal)
  static const TextStyle valueLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Valor pequeno: "R$ 89,90" (valores em listas)
  static const TextStyle valueSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // --- Legendas e labels ---
  /// Labels de formulário, legendas de gráficos
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // --- Botões ---
  /// Texto dentro de botões
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}