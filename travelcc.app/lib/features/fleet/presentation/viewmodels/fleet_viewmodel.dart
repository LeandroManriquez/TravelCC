import 'package:flutter/material.dart';

class Truck {
  final String id;
  final String driver;
  final String status;
  final Color statusColor;

  Truck({
    required this.id,
    required this.driver,
    required this.status,
    required this.statusColor,
  });
}

class FleetViewModel extends ChangeNotifier {
  final List<Truck> trucks = [
    Truck(
      id: 'TRK-023',
      driver: 'Juan Pérez',
      status: 'En ruta',
      statusColor: Colors.green,
    ),
    Truck(
      id: 'TRK-018',
      driver: 'María González',
      status: 'Detenido',
      statusColor: Colors.orange,
    ),
    Truck(
      id: 'TRK-045',
      driver: 'Carlos Ruiz',
      status: 'Alerta',
      statusColor: Colors.red,
    ),
    Truck(
      id: 'TRK-012',
      driver: 'Ana Silva',
      status: 'En ruta',
      statusColor: Colors.green,
    ),
    Truck(
      id: 'TRK-033',
      driver: 'Pedro López',
      status: 'En ruta',
      statusColor: Colors.green,
    ),
  ];
}
