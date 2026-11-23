import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/travel_api.dart';

class DriverMenuViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;

  String driverName = 'Conductor';
  String driverEmail = '';
  String driverShortId = '---';
  String fleetName = 'Modo Libre (Sin Flota)';
  bool hasFleet = false;

  String assignedUnit = 'Sin camión configurado';
  String truckDimensions = 'Configura tu unidad';
  String? linkCode;
  String? linkCodeExpiresAt;
  bool isGeneratingCode = false;

  DriverMenuViewModel() {
    loadDriverData();
  }

  Future<void> loadDriverData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await TravelApi.get('/me');
      final data = (res['data'] as Map<String, dynamic>?) ?? {};

      driverName = data['full_name']?.toString() ?? 'Conductor';
      driverEmail = data['email']?.toString() ?? '';
      final fullId = data['id']?.toString() ?? '';
      driverShortId = fullId.length >= 8
          ? fullId.substring(0, 8).toUpperCase()
          : (fullId.isEmpty ? '---' : fullId.toUpperCase());

      final fleet = data['fleet'] as Map<String, dynamic>?;
      if (fleet != null && fleet['name'] != null) {
        hasFleet = true;
        fleetName = 'Flota: ${fleet['name']}';
      } else {
        hasFleet = false;
        fleetName = 'Modo Libre (Sin Flota)';
      }

      final trucks = (data['trucks'] as List<dynamic>?) ?? [];
      if (trucks.isNotEmpty && trucks.first is Map<String, dynamic>) {
        final t = trucks.first as Map<String, dynamic>;
        final plate = t['plate']?.toString() ?? 'SIN-PATENTE';
        final h = t['height_meters'];
        final w = t['weight_tons'];
        assignedUnit = 'Patente $plate';
        truckDimensions = '${h ?? "-"}m alto · ${w ?? "-"}T peso';
      } else {
        assignedUnit = 'Sin camión registrado';
        truckDimensions = 'Toca el camión en el mapa';
      }
    } on TravelApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'No se pudo cargar tu perfil de conductor.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> generateLinkCode() async {
    isGeneratingCode = true;
    notifyListeners();

    try {
      final res = await TravelApi.post('/me/link-code');
      final data = (res['data'] as Map<String, dynamic>?) ?? {};
      linkCode = data['code']?.toString();
      linkCodeExpiresAt = data['expires_at']?.toString();
      return linkCode;
    } on TravelApiException catch (e) {
      throw Exception(e.message);
    } finally {
      isGeneratingCode = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}