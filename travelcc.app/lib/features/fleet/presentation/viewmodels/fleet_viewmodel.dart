import 'package:flutter/material.dart';

import '../../../../core/network/travel_api.dart';
import '../../../../core/theme/app_colors.dart';

enum TruckOperationalState {
  inRoute,
  stopped,
  disconnected,
}

class Truck {
  final String id;
  final String plate;
  final String driver;
  final String? driverId;
  final String? driverPhone;
  final String dimensions;
  final TruckOperationalState operationalState;
  final String status;
  final Color statusColor;
  final double? lat;
  final double? lng;
  final double? rawSpeedKmh;
  final String? recordedAt;

  Truck({
    required this.id,
    required this.plate,
    required this.driver,
    this.driverId,
    this.driverPhone,
    required this.dimensions,
    required this.operationalState,
    required this.status,
    required this.statusColor,
    this.lat,
    this.lng,
    this.rawSpeedKmh,
    this.recordedAt,
  });

  bool get hasPosition => lat != null && lng != null;

  /// Si está desconectado o detenido, muestra 0 km/h; si está en ruta, la última velocidad registrada.
  double get displaySpeedKmh {
    if (operationalState == TruckOperationalState.inRoute) {
      return rawSpeedKmh ?? 0.0;
    }
    return 0.0;
  }

  String get formattedLastUpdate {
    if (recordedAt == null) return 'Sin registros de telemetría';
    final parsed = DateTime.tryParse(recordedAt!);
    if (parsed == null) return recordedAt!;

    final diff = DateTime.now().toUtc().difference(parsed.toUtc());
    if (diff.inSeconds < 60) return 'Hace unos segundos';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }

  factory Truck.fromJson(Map<String, dynamic> json) {
    final driverObj = json['driver'] as Map<String, dynamic>?;
    final pos = json['last_position'] as Map<String, dynamic>?;
    final h = json['height_meters'];
    final w = json['weight_tons'];
    final recordedAt = pos?['recorded_at']?.toString();
    final speed = (pos?['speed_kmh'] as num?)?.toDouble() ?? 0.0;

    bool isWithin20Min = false;
    if (recordedAt != null) {
      final parsed = DateTime.tryParse(recordedAt);
      if (parsed != null &&
          DateTime.now().toUtc().difference(parsed.toUtc()).inMinutes <= 20) {
        isWithin20Min = true;
      }
    }

    late final TruckOperationalState state;
    late final String statusLabel;
    late final Color color;

    if (!isWithin20Min || pos == null) {
      state = TruckOperationalState.disconnected;
      statusLabel = 'Desconectado';
      color = AppColors.textMuted;
    } else if (speed <= 3.0) {
      state = TruckOperationalState.stopped;
      statusLabel = 'Detenido';
      color = AppColors.warningYellow;
    } else {
      state = TruckOperationalState.inRoute;
      statusLabel = 'En ruta';
      color = AppColors.successGreen;
    }

    return Truck(
      id: json['truck_id']?.toString() ?? '',
      plate: json['plate']?.toString() ?? 'SIN-PATENTE',
      driver: driverObj?['full_name']?.toString() ?? 'Sin conductor asignado',
      driverId: driverObj?['id']?.toString(),
      driverPhone: driverObj?['phone']?.toString(),
      dimensions: '${h ?? "-"}m alto / ${w ?? "-"}T peso',
      operationalState: state,
      status: statusLabel,
      statusColor: color,
      lat: (pos?['lat'] as num?)?.toDouble(),
      lng: (pos?['lng'] as num?)?.toDouble(),
      rawSpeedKmh: (pos?['speed_kmh'] as num?)?.toDouble(),
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