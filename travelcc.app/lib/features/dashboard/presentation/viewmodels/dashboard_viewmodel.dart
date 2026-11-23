import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/travel_api.dart';

class DashboardViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;

  String fleetName = 'Mi Flota';
  String planStatus = 'active';
  int totalTrucks = 0;
  int activeTrucks = 0;

  bool get isPlanActive => planStatus == 'active';

  double get availabilityPercent {
    if (totalTrucks == 0) return 0;
    return (activeTrucks / totalTrucks) * 100;
  }

  DashboardViewModel() {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final meRes = await TravelApi.get('/me');
      final meData = (meRes['data'] as Map<String, dynamic>?) ?? {};
      final fleet = meData['fleet'] as Map<String, dynamic>?;
      if (fleet != null) {
        fleetName = fleet['name']?.toString() ?? 'Mi Flota';
        planStatus = fleet['plan_status']?.toString() ?? 'inactive';
      }

      if (isPlanActive) {
        final trucksRes = await TravelApi.get('/fleet/trucks');
        final trucksData = (trucksRes['data'] as Map<String, dynamic>?) ?? {};
        final summary = (trucksData['summary'] as Map<String, dynamic>?) ?? {};
        totalTrucks = (summary['total_trucks'] as num?)?.toInt() ?? 0;
        activeTrucks = (summary['active_trucks'] as num?)?.toInt() ?? 0;
      } else {
        totalTrucks = 0;
        activeTrucks = 0;
      }
    } on TravelApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'No se pudo cargar el resumen de flota.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> activateDemoPlan() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await TravelApi.post('/billing/simulate-checkout');
      await loadDashboard();
      return true;
    } on TravelApiException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> onLogout() async {
    await Supabase.instance.client.auth.signOut();
  }
}