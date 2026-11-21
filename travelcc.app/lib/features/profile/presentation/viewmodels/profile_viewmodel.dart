import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  final String driverName = 'Carlos Méndez';
  final String fleetId = 'TC-84920';
  final String rut = '15.892.401-2';
  final String license = 'Clase A5';
  final String licenseExpiry = '14/11/2027';
  final double odometer = 142850;
  final String assignedUnit = 'Scania R500';
  final String unitPatent = 'KJ-TR-91';
  final String syncTime = '14:32 CLT';

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  void toggleEdit() {
    _isEditing = !_isEditing;
    notifyListeners();
    debugPrint('✏️ Editando perfil...');
  }

  void logout() {
    debugPrint('🚪 Cerrando sesión...');
  }

  String formatOdometer(double km) {
    return km
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
