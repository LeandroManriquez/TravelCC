import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/travel_api.dart';

class ProfileViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;

  String driverName = 'Conductor';
  String email = '';
  String shortId = '---';
  String? fleetName;
  String? fleetId;

  String assignedUnit = 'Sin camión asignado';
  String unitPatent = '---';
  String unitDimensions = 'No configuradas';

  String? linkCode;
  bool isGeneratingCode = false;

  ProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await TravelApi.get('/me');
      final data = (res['data'] as Map<String, dynamic>?) ?? {};

      driverName = data['full_name']?.toString() ?? 'Conductor';
      email = data['email']?.toString() ?? '';
      final fullId = data['id']?.toString() ?? '';
      shortId = fullId.length >= 8
          ? fullId.substring(0, 8).toUpperCase()
          : (fullId.isEmpty ? '---' : fullId.toUpperCase());

      final fleet = data['fleet'] as Map<String, dynamic>?;
      fleetName = fleet?['name']?.toString();
      fleetId = fleet?['id']?.toString();

      final trucks = (data['trucks'] as List<dynamic>?) ?? [];
      if (trucks.isNotEmpty && trucks.first is Map<String, dynamic>) {
        final t = trucks.first as Map<String, dynamic>;
        unitPatent = t['plate']?.toString() ?? '---';
        assignedUnit = 'Unidad $unitPatent';
        unitDimensions =
            '${t['height_meters'] ?? "-"}m alto / ${t['weight_tons'] ?? "-"}T peso';
      } else {
        unitPatent = '---';
        assignedUnit = 'Sin camión registrado';
        unitDimensions = 'Configura tu unidad';
      }
    } on TravelApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'No se pudo cargar el perfil.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateName(String newName) async {
    try {
      final res = await TravelApi.patch('/me', {'full_name': newName.trim()});
      final updated = (res['data'] as Map<String, dynamic>?) ?? {};
      driverName = updated['full_name']?.toString() ?? newName.trim();
      notifyListeners();
      return null;
    } on TravelApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Error al actualizar nombre.';
    }
  }

  Future<String?> generateLinkCode() async {
    isGeneratingCode = true;
    notifyListeners();

    try {
      final res = await TravelApi.post('/me/link-code');
      final data = (res['data'] as Map<String, dynamic>?) ?? {};
      linkCode = data['code']?.toString();
      return linkCode;
    } on TravelApiException catch (e) {
      throw Exception(e.message);
    } finally {
      isGeneratingCode = false;
      notifyListeners();
    }
  }

  Future<String?> leaveFleet() async {
    try {
      await TravelApi.post('/me/leave-fleet');
      await loadProfile();
      return null;
    } on TravelApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo salir de la flota.';
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}