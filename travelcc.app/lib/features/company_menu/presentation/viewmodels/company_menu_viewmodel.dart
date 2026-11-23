import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/travel_api.dart';

class FleetTruckSummary {
  final String truckId;
  final String plate;
  final double? heightMeters;
  final double? weightTons;
  final String? driverId;
  final String? driverName;
  final double? lat;
  final double? lng;
  final double? speedKmh;
  final String? recordedAt;

  FleetTruckSummary({
    required this.truckId,
    required this.plate,
    this.heightMeters,
    this.weightTons,
    this.driverId,
    this.driverName,
    this.lat,
    this.lng,
    this.speedKmh,
    this.recordedAt,
  });

  bool get hasPosition => lat != null && lng != null;

  bool get isRecentlyActive {
    if (recordedAt == null) return false;
    final parsed = DateTime.tryParse(recordedAt!);
    if (parsed == null) return false;
    return DateTime.now().toUtc().difference(parsed.toUtc()).inMinutes <= 5;
  }

  factory FleetTruckSummary.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>?;
    final pos = json['last_position'] as Map<String, dynamic>?;
    return FleetTruckSummary(
      truckId: json['truck_id']?.toString() ?? '',
      plate: json['plate']?.toString() ?? 'SIN-PATENTE',
      heightMeters: (json['height_meters'] as num?)?.toDouble(),
      weightTons: (json['weight_tons'] as num?)?.toDouble(),
      driverId: driver?['id']?.toString(),
      driverName: driver?['full_name']?.toString(),
      lat: (pos?['lat'] as num?)?.toDouble(),
      lng: (pos?['lng'] as num?)?.toDouble(),
      speedKmh: (pos?['speed_kmh'] as num?)?.toDouble(),
      recordedAt: pos?['recorded_at']?.toString(),
    );
  }
}

class CompanyMenuViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;

  String bossName = 'Administrador';
  String bossEmail = '';
  String companyName = 'Mi Flota';
  String fleetId = '';
  String planStatus = 'inactive';
  int totalTrucks = 0;
  int inTransit = 0;
  String syncTime = '--:--';
  List<FleetTruckSummary> trucks = [];

  bool get isPlanActive => planStatus == 'active';

  double get availability {
    if (totalTrucks == 0) return 0.0;
    return (inTransit / totalTrucks) * 100.0;
  }

  int get stationaryCount =>
      (totalTrucks - inTransit) < 0 ? 0 : (totalTrucks - inTransit);

  CompanyMenuViewModel() {
    loadCompanyData();
  }

  Future<void> loadCompanyData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final meRes = await TravelApi.get('/me');
      final meData = (meRes['data'] as Map<String, dynamic>?) ?? {};
      bossName = meData['full_name']?.toString() ?? 'Administrador';
      bossEmail = meData['email']?.toString() ?? '';
      fleetId = meData['fleet_id']?.toString() ?? '';

      final fleet = meData['fleet'] as Map<String, dynamic>?;
      if (fleet != null) {
        companyName = fleet['name']?.toString() ?? 'Mi Flota';
        planStatus = fleet['plan_status']?.toString() ?? 'inactive';
      }

      if (isPlanActive) {
        final trucksRes = await TravelApi.get('/fleet/trucks');
        final data = (trucksRes['data'] as Map<String, dynamic>?) ?? {};
        final summary = (data['summary'] as Map<String, dynamic>?) ?? {};
        final rawList = (data['trucks'] as List<dynamic>?) ?? [];

        trucks = rawList
            .whereType< Map< String, dynamic > >()
            .map(FleetTruckSummary.fromJson)
            .toList();
        totalTrucks =
            (summary['total_trucks'] as num?)?.toInt() ?? trucks.length;
        inTransit = (summary['active_trucks'] as num?)?.toInt() ?? 0;
      } else {
        trucks = [];
        totalTrucks = 0;
        inTransit = 0;
      }

      final now = DateTime.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');
      syncTime = '$hh:$mm';
    } on TravelApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'No se pudo cargar la información de la empresa.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateBossName(String newName) async {
    try {
      final res = await TravelApi.patch('/me', {'full_name': newName.trim()});
      final updated = (res['data'] as Map<String, dynamic>?) ?? {};
      bossName = updated['full_name']?.toString() ?? newName.trim();
      notifyListeners();
      return null;
    } on TravelApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo actualizar el nombre.';
    }
  }

  Future<String?> activateDemoPlan() async {
    try {
      await TravelApi.post('/billing/simulate-checkout');
      await loadCompanyData();
      return null;
    } on TravelApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo activar el plan.';
    }
  }

  Future<String?> linkDriverByCode(String code) async {
    try {
      final res = await TravelApi.post('/fleet/link', {'code': code.trim()});
      await loadCompanyData();
      return res['message']?.toString() ?? 'Conductor enlazado correctamente';
    } on TravelApiException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> unlinkDriver(String driverId) async {
    try {
      await TravelApi.delete('/fleet/drivers/$driverId');
      await loadCompanyData();
    } on TravelApiException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}