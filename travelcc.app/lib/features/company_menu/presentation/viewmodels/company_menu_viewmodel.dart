import 'package:flutter/material.dart';

class CompanyMenuViewModel extends ChangeNotifier {
  final String companyName = 'Transportes TransAndes S.A.';
  final String companyRut = '76.452.190-K';
  final String node = 'Nodo Santiago Sur';
  final int totalTrucks = 18;
  final int inTransit = 14;
  final double availability = 94.2;
  final String syncTime = '10:42 AM';

  void goToProfile() => debugPrint('🏢 Perfil Corporativo');
  void goToSettings() => debugPrint('⚙️ Configuración');
  void goToFleet() => debugPrint('🚛 Flota de Camiones');
  void goToMonitoring() => debugPrint('📡 Monitoreo y Rutas');
  void goToDrivers() => debugPrint('👥 Conductores Asignados');
  void logout() => debugPrint('🚪 Cerrar Sesión Corporativa');
}
