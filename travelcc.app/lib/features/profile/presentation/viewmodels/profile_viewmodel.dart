import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/travel_api.dart';
class ProfileViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;

  String driverName = 'Conductor';
  String email = '';
  String phone = '';
  String shortId = '---';
  String? fleetName;
  String? fleetId;

  String assignedUnit = 'Sin camión asignado';
  String unitPatent = '---';
  String unitDimensions = 'No configuradas';

  String? linkCode;
  DateTime? linkCodeExpiresAt;
  bool isGeneratingCode = false;
  bool isLeavingFleet = false;

  bool get isInFleet => fleetId != null && fleetId!.isNotEmpty;

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
      email = data['email']?.toString() ??
          Supabase.instance.client.auth.currentUser?.email ??
          '';
      phone = data['phone']?.toString() ?? '';

      final fullId = data['id']?.toString() ?? '';
      shortId = fullId.length >= 8
          ? fullId.substring(0, 8).toUpperCase()
          : (fullId.isEmpty ? '---' : fullId.toUpperCase());

      final fleet = data['fleet'] as Map<String, dynamic>?;
      fleetName = fleet?['name']?.toString();
      fleetId = fleet?['id']?.toString() ?? data['fleet_id']?.toString();

      if (isInFleet) {
        linkCode = null;
        linkCodeExpiresAt = null;
      }

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
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return 'El nombre no puede estar vacío.';

    try {
      final res = await TravelApi.patch('/me', {'full_name': trimmed});
      final updated = (res['data'] as Map<String, dynamic>?) ?? {};
      driverName = updated['full_name']?.toString() ?? trimmed;
      notifyListeners();
      return null;
    } on TravelApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Error al actualizar nombre.';
    }
  }

  Future<String?> updatePhone(String newPhone) async {
    final trimmed = newPhone.trim();
    if (trimmed.isEmpty) return 'Ingresa un número de teléfono válido.';

    try {
      final res = await TravelApi.patch('/me', {'phone': trimmed});
      final updated = (res['data'] as Map<String, dynamic>?) ?? {};
      phone = updated['phone']?.toString() ?? trimmed;
      notifyListeners();
      return null;
    } on TravelApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Error al actualizar el teléfono.';
    }
  }

  Future<String?> generateLinkCode() async {
    isGeneratingCode = true;
    notifyListeners();

    try {
      final res = await TravelApi.post('/me/link-code');
      final data = (res['data'] as Map<String, dynamic>?) ?? {};
      linkCode = data['code']?.toString();

      final rawExpiry = data['expires_at']?.toString();
      linkCodeExpiresAt =
          rawExpiry != null ? DateTime.tryParse(rawExpiry)?.toLocal() : null;

      return null;
    } on TravelApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo generar el código de enlace.';
    } finally {
      isGeneratingCode = false;
      notifyListeners();
    }
  }

  Future<String?> leaveFleet() async {
    isLeavingFleet = true;
    notifyListeners();

    try {
      await TravelApi.post('/me/leave-fleet');
      fleetId = null;
      fleetName = null;
      linkCode = null;
      linkCodeExpiresAt = null;
      await loadProfile();
      return null;
    } on TravelApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo salir de la flota.';
    } finally {
      isLeavingFleet = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}