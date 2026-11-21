import 'package:flutter/material.dart';

class TruckDetailViewModel extends ChangeNotifier {
  final String truckId = 'TRK-023';
  final String driverName = 'Juan Pérez';
  final String driverPhone = '+56 9 1234 5678';
  final String currentStatus = 'En ruta';
  final double speed = 85.5;
  final double fuelLevel = 72.0;
  final String lastUpdate = 'Hace 2 minutos';

  void callDriver() {
    debugPrint('Llamando a $driverName...');
  }
}
