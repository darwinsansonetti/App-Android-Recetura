import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === Colores de marca (basados en la web oficial) ===
  static const primary = Color(0xFF1E3A8A); // Azul marino del topbar
  static const primaryDark = Color(0xFF152C6B); // Variante más oscura
  static const primaryLight = Color(0xFF3B5FC7); // Variante clara

  static const secondary = Color(0xFF1AC7A8); // Verde turquesa del botón login
  static const secondaryDark = Color(0xFF15A88D);
  static const secondaryLight = Color(0xFF5DD9C1);

  static const accent = Color(0xFF3DD35F); // Verde neón del logo
  static const accentDark = Color(0xFF2BBF4D);

  // === Estados ===
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // === Superficies ===
  static const background = Color(0xFFF5F5F7); // Fondo general
  static const surface = Color(0xFFFFFFFF); // Cards
  static const surfaceAlt = Color(0xFFF9FAFB); // Inputs en reposo

  // === Textos ===
  static const textPrimary = Color(0xFF1E3A5F); // Azul oscuro
  static const textSecondary = Color(0xFF6B7280); // Gris medio
  static const textTertiary = Color(0xFF9CA3AF); // Gris claro

  // === Bordes ===
  static const borderLight = Color(0xFFE5E7EB);
  static const borderMedium = Color(0xFFD1D5DB);
  static const borderFocus = Color(0xFF3B82F6); // Azul al enfocar input

  // === Especiales ===
  static const whatsapp = Color(0xFF25D366);
  static const priceSpecial = Color(0xFF10B981); // Precio especial en verde
  static const priceRegular = Color(0xFF1E3A8A); // Precio normal azul
}
