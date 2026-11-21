import 'package:flutter/material.dart';

class AppColors {
  // Colores originales
  static const Color background = Color(0xFF06080D);
  static const Color panel = Color(0xFF0B1018);
  static const Color primary = Color(0xFFFF6B1A);
  static const Color secondary = Color(0xFF16B9FF);
  static const Color success = Color(0xFF8CFF00);
  static const Color textPrimary = Color(0xFFEAF2F5);
  static const Color textMuted = Color(0xFF8FA3AD);
  static const Color textDisabled = Color(0xFF52666F);
  static const Color buttonSmallBorder = Color(0xFF3A3A3A);
  static const Color panelSecondary = Color(0xFF0E1620);

  // Nuevos colores semánticos
  static const Color backgroundDark = Color(0xFF121212);
  static const Color panelDark = Color(0xFF1E1E1E);
  static const Color actionOrange = Color(0xFFFF6B00);
  static const Color warningYellow = Color(0xFFFFB800);
  static const Color criticalRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF4CAF50);

  // 👇 ESTE ES EL QUE FALTABA Y TE CAUSABA EL ERROR
  static const Color error = Color(0xFFE53935);
}
