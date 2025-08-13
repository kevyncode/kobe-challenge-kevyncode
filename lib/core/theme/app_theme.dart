import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centraliza todas as constantes de cores da aplicação
class AppColors {
  // Cores principais
  static const Color primary = Color(0xFF4A90E2);
  static const Color secondary = Color(0xFF00D4AA);

  // Cores de fundo
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2D2D2D);

  // Cores de texto
  static const Color onPrimary = Colors.white;
  static const Color onSurface = Color(0xFFB0B0B0);
  static const Color onSurfaceVariant = Color(0xFF9E9E9E);
  static const Color textPrimary = Colors.white;

  // Estados de status do personagem
  static const Color statusAlive = Color(0xFF55CC44);
  static const Color statusDead = Color(0xFFD63D2E);
  static const Color statusUnknown = Color(0xFF9E9E9E);

  // Cores de sistema
  static const Color error = Color(0xFFD63D2E);
  static const Color success = Color(0xFF55CC44);
}

/// Centraliza todos os estilos de texto da aplicação
class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.lato(
    color: AppColors.onPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get displayMedium => GoogleFonts.lato(
    color: AppColors.onPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get headlineMedium => GoogleFonts.lato(
    color: AppColors.onPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get titleMedium => GoogleFonts.lato(
    color: AppColors.onPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get bodyLarge =>
      GoogleFonts.lato(color: AppColors.onPrimary, fontSize: 16);

  static TextStyle get bodyMedium =>
      GoogleFonts.lato(color: AppColors.onSurface, fontSize: 14);

  static TextStyle get bodySmall =>
      GoogleFonts.lato(color: AppColors.onSurface, fontSize: 12);

  static TextStyle get labelMedium =>
      GoogleFonts.lato(color: AppColors.onSurface, fontSize: 12);
}

/// Centraliza todas as dimensões e espaçamentos
class AppSpacing {
  static const double extraSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;

  // Aliases para compatibilidade
  static const double xs = extraSmall;
  static const double sm = small;
  static const double md = medium;
  static const double lg = large;
  static const double xl = extraLarge;
}

/// Centraliza valores de border radius
class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;

  // Aliases para compatibilidade
  static const double sm = small;
  static const double md = medium;
  static const double lg = large;
  static const double xl = extraLarge;
}

/// Centraliza dimensões específicas de componentes
class AppSizes {
  static const double avatarSmall = 60.0;
  static const double avatarMedium = 120.0;
  static const double avatarLarge = 200.0;

  static const double cardMinHeight = 80.0;
  static const double cardMaxHeight = 200.0;

  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  // Tamanhos específicos para personagens
  static const double characterImageSize = 60.0;
  static const double characterImageLarge = 120.0;
}

/// Centraliza constantes de animação
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
