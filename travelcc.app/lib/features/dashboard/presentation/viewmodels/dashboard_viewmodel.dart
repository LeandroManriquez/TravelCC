import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  // Datos simulados para el Hito 1 (luego vendrán del Backend)
  final int activeTrucks = 12;
  final int pendingAlerts = 3;
  final double completedRoutes = 85.5; // Porcentaje

  void onLogout() {
    debugPrint('Cerrando sesión...');
  }
}
