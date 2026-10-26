import 'package:flutter/material.dart';

/// ViewModel de la pantalla de Inicio.
/// En MVVM, este es el "cerebro". Separa la lógica de la vista.
class HomeViewModel extends ChangeNotifier {
  // Datos que la vista va a mostrar
  final String eyebrow = "TRANSPORTE PESADO · INTELIGENCIA COLECTIVA";
  final String title = "La ruta que\naprende.";
  final String subtitle =
      "Navegación adaptada a camiones, monitoreo de flotas y un mapa que mejora con la experiencia real de sus conductores.";

  // Método de ejemplo para manejar interacciones
  void onExploreProject() {
    debugPrint('El usuario hizo clic en Explorar Proyecto');
  }
}
