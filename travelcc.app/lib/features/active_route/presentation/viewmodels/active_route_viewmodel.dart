import 'package:flutter/material.dart';

class ActiveRouteViewModel extends ChangeNotifier {
  final String nextInstruction = 'A 800 m gire a la derecha';
  final String nextRoad = 'Enlace Ruta 5 Norte';
  final String warning = 'Precaución: Puente 4.2m a 2.5 km';
  final int remainingMinutes = 45;
  final int remainingKm = 38;
  final String destination = 'Antofagasta';

  bool _isNavigating = true;
  bool get isNavigating => _isNavigating;

  void cancelNavigation() {
    _isNavigating = false;
    notifyListeners();
    debugPrint('🛑 Navegación cancelada');
  }
}
