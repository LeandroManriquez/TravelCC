import 'package:flutter/material.dart';

class DriverMenuViewModel extends ChangeNotifier {
  final String driverName = 'Carlos Méndez';
  final String driverId = 'CC-8902';
  final String license = 'Lic. A5';
  final String level = 'Chofer Profesional · Nivel Oro';
  final String hosRemaining = '06h 42m';
  final double routeScore = 98.4;
  final int kmTurno = 412;
  final String assignedUnit = 'Freightliner Cascadia #504';
  final String grossWeight = '36,200 kg';

  void goToProfile() => debugPrint('👤 Mi Perfil');
  void goToSettings() => debugPrint('⚙️ Configuración');
  void goToHistory() => debugPrint('📜 Historial de Viajes');
  void goToSupport() => debugPrint('🎧 Soporte en Ruta 24/7');
  void logout() => debugPrint('🚪 Cerrar Sesión');
}
