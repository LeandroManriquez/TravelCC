import 'package:flutter/material.dart';

class StatesViewModel extends ChangeNotifier {
  void activateLocation() {
    debugPrint('📍 Activando ubicación...');
  }

  void retryConnection() {
    debugPrint('🔄 Reintentando conexión...');
  }

  void continueOffline() {
    debugPrint('📡 Continuando en modo offline...');
  }

  void addNewUnitOrRoute() {
    debugPrint('➕ Agregando nueva unidad o ruta...');
  }

  void showPermissionsGuide() {
    debugPrint('📖 Mostrando guía de permisos...');
  }
}
