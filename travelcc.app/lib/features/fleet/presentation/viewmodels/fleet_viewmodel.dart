import 'package:flutter/material.dart';

import '../../../../core/network/travel_api.dart';
import '../../../../core/theme/app_colors.dart';

class Truck {
  final String id;
  final String plate;
  final String driver;
  final String? driverId;
  final String dimensions;
  final String status;
  final Color statusColor;
  final double? speedKmh;
  final String? recordedAt;

  Truck({
    required this.id,
    required this.plate,
    required this.driver,
    this.driverId,
    required this.dimensions,
    required this.status,
    required this.statusColor,
    this.speedKmh,
    this.recordedAt,
  });

  factory Truck.fromJson(Map<String, dynamic> json) {
    final driverObj = json['driver'] as Map<String, dynamic>?;
    final pos = json['last_position'] as Map<String, dynamic>?;
    final h = json['height_meters'];
    final w = json['weight_tons'];
    final recordedAt = pos?['recorded_at']?.toString();

    bool isActive = false;
    if (recordedAt != null) {
      final parsed = DateTime.tryParse(recordedAt);
      if (parsed != null &&
          DateTime.now().toUtc().difference(parsed.toUtc()).inMinutes <= 5) {
        isActive = true;
      }
    }

    final statusLabel = isActive
        ? 'En ruta'
        : (pos != null ? 'Detenido' : 'Sin señal GPS');
    final color = isActive
        ? AppColors.successGreen
        : (pos != null ? AppColors.warningYellow : AppColors.secondary);

    return Truck(
      id: json['truck_id']?.toString() ?? '',
      plate: json['plate']?.toString() ?? 'SIN-PATENTE',
      driver: driverObj?['full_name']?.toString() ?? 'Sin conductor asignado',
      driverId: driverObj?['id']?.toString(),
      dimensions: '${h ?? "-"}m alto / ${w ?? "-"}T peso',
      status: statusLabel,
      statusColor: color,
      speedKmh: (pos?['speed_kmh'] as num?)?.toDouble(),
      recordedAt: recordedAt,
    );
  }
}

class FleetViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;
  List<Truck> trucks = [];

  FleetViewModel() {
    loadTrucks();
  }

  Future<void> loadTrucks() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await TravelApi.get('/fleet/trucks');
      final data = (res['data'] as Map<String, dynamic>?) ?? {};
      final list = (data['trucks'] as List<dynamic>?) ?? [];
      trucks = list
          .whereType< Map< String, dynamic > >()
          .map(Truck.fromJson)
          .toList();
    } on TravelApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'No se pudo cargar la flota.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> linkDriverByCode(String code) async {
    try {
      final res = await TravelApi.post('/fleet/link', {'code': code.trim()});
      await loadTrucks();
      return res['message']?.toString() ?? 'Conductor enlazado';
    } on TravelApiException catch (e) {
      throw Exception(e.message);
    }
  }
}