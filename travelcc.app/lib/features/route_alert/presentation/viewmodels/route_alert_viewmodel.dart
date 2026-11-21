import 'package:flutter/material.dart';

class RouteAlertViewModel extends ChangeNotifier {
  final String route = 'Ruta CH-60 · Km 34.5';
  final String restriction = 'Paso Bajo Nivel Ferroviario';
  final double maxHeight = 3.80;
  final double truckHeight = 4.20;
  final double maxWeight = 30.0;
  final double truckWeight = 45.0;
  final String deviation = 'Salida 34B (Variante Cargas)';
  final double deviationDistance = 850;

  void viewAlternativeRoute() {
    debugPrint('🛣️ Viendo ruta alternativa...');
  }

  void stopInSafeZone() {
    debugPrint('🛑 Deteniéndose en zona segura...');
  }
}
