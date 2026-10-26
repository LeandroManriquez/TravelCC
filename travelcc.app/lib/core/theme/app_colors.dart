import 'package:flutter/material.dart';

/// Paleta de colores de TRAVEL CC.
/// Extraída de los principios DRY: se define una vez, se usa en toda la app.
abstract final class AppColors {
  // === Fondos (Identidad oscura tech) ===
  static const Color background = Color(0xFF06080D);
  static const Color panel = Color(0xFF0B1018);
  static const Color panelSecondary = Color(0xFF0E1620);

  // === Textos ===
  static const Color textPrimary = Color(0xFFEAF2F5);
  static const Color textMuted = Color(0xFF8FA3AD);
  static const Color textDisabled = Color(0xFF52666F);

  // === Colores de Marca (Camioneros: Naranja, Azul, Verde) ===
  static const Color primary = Color(0xFFFF6B1A);       // Naranja camión
  static const Color primaryVariant = Color(0xFFFF8C42); // Naranja suave
  static const Color secondary = Color(0xFF1E88E5);      // Azul corporativo
  static const Color secondaryVariant = Color(0xFF42A5F5); // Azul claro
  static const Color success = Color(0xFF00C853);        // Verde semáforo
  static const Color successVariant = Color(0xFF4CAF50); // Verde suave

  // === Botones Pequeños (Negro/Gris como pediste) ===
  static const Color buttonSmall = Color(0xFF1A1A1A);
  static const Color buttonSmallHover = Color(0xFF2A2A2A);
  static const Color buttonSmallBorder = Color(0xFF3A3A3A);

  // === Semánticos (Alertas) ===
  static const Color warning = Color(0xFFFFB84D);
  static const Color error = Color(0xFFFF5470);
}