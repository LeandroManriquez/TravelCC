import 'package:flutter/material.dart';

class NoRouteViewModel extends ChangeNotifier {
  final double truckHeight = 4.20;
  final double truckWeight = 48.5;
  final String hazmatClass = 'Clase 3';
  final String bridgeName = 'Puente Ferroviario Km 34';
  final double bridgeMaxHeight = 3.80;
  final double heightDeficit = -0.40;
  final String passName = 'Paso El Cobre';
  final double routeLimit = 45.0;

  void adjustParameters() => debugPrint('⚙️ Ajustar Parámetros del Camión');
  void contactSupport() => debugPrint('🎧 Contactar Soporte Logístico');
  void forceRecalculate() => debugPrint('🔄 Forzar Recálculo');
}
