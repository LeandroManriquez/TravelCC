import 'package:flutter/material.dart';

/// ViewModel de la pantalla del Mapa.
/// Maneja el estado del mapa y las interacciones del usuario.
class MapViewModel extends ChangeNotifier {
  // Datos simulados para el Hito 1
  String currentLocation = "Ruta 5 Sur, Km 125";
  bool isTracking = true; // Simula si el GPS está activo

  // Método para centrar el mapa en la ubicación actual
  void onCenterLocation() {
    debugPrint('Centrando mapa en: $currentLocation');
    // Aquí iría la lógica real del GPS en el Hito 2
  }

  // Método para buscar una dirección
  void onSearch(String query) {
    debugPrint('Buscando: $query');
    // Aquí iría la lógica de búsqueda en el Hito 2
  }

  // Método para abrir configuración
  void onSettings() {
    debugPrint('Abriendo configuración del mapa');
  }
}
