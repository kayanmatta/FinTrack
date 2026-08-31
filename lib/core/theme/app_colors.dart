import 'package:flutter/material.dart';

/// Cores padrão do Centivo.
/// Usar essas cores em vez de valores hex diretos em cada tela.
class AppColors {
  AppColors._();

  // --- Fundos ---
  /// Fundo principal da tela (cinza escuro)
  static const Color background = Color(0xFF1A1A2E);
  /// Fundo de barras laterais e headers
  static const Color surface = Color(0xFF222240);
  /// Fundo dos cards e containers
  static const Color card = Color(0xFF2A2A4A);

  // --- Cores primárias ---
  /// Roxo principal — botões, item selecionado no menu
  static const Color primary = Color(0xFF6C2BD9);
  /// Roxo claro — hover, estados ativos
  static const Color primaryLight = Color(0xFF9F67FF);

  // --- Cores semânticas ---
  /// Verde — receitas, valores positivos, economia
  static const Color income = Color(0xFF10B981);
  /// Vermelho — despesas, valores negativos, alerta
  static const Color expense = Color(0xFFEF4444);
  /// Azul — informação, links, ícones neutros
  static const Color info = Color(0xFF3B82F6);
  /// Amarelo — aviso, atenção
  static const Color warning = Color(0xFFF59E0B);

  // --- Textos ---
  /// Texto principal (branco)
  static const Color textPrimary = Color(0xFFFFFFFF);
  /// Texto secundário (cinza claro — legendas, timestamps)
  static const Color textSecondary = Color(0xFF9CA3AF);
  /// Texto desabilitado (cinza mais escuro)
  static const Color textDisabled = Color(0xFF6B7280);

  // --- Bordas e divisores ---
  /// Cor das bordas de cards e inputs
  static const Color border = Color(0xFF374151);
  /// Linha divisória entre seções
  static const Color divider = Color(0xFF2D2D4A);

  // --- Paleta do redesign (mockup) ---
  /// Fundo da barra lateral desktop e barra inferior mobile (quase preto)
  static const Color sidebar = Color(0xFF0E0E17);
  /// Fundo escuro das telas mobile
  static const Color backgroundDark = Color(0xFF0B0B12);
  /// Card escuro sobre o fundo do app (dashboard)
  static const Color cardDark = Color(0xFF151527);
}