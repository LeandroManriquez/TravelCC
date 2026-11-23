import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/travel_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../fleet/presentation/viewmodels/fleet_viewmodel.dart';

class TruckDetailViewModel extends ChangeNotifier {
  Truck? _truck;
  bool isRefreshing = false;

  TruckDetailViewModel(Truck? initialTruck) {
    _truck = initialTruck;
  }

  Truck? get truck => _truck;

  String get plate => _truck?.plate ?? 'Sin patente';
  String get dimensions => _truck?.dimensions ?? '';
  String get driverName => _truck?.driver ?? 'Sin conductor asignado';
  String get driverPhone => (_truck?.driverPhone?.trim().isNotEmpty ?? false)
      ? _truck!.driverPhone!.trim()
      : 'Sin teléfono registrado';

  bool get hasPhone => (_truck?.driverPhone?.trim().isNotEmpty ?? false);

  String get currentStatus => _truck?.status ?? 'Desconectado';
  Color get statusColor => _truck?.statusColor ?? AppColors.textMuted;

  IconData get statusIcon {
    switch (_truck?.operationalState) {
      case TruckOperationalState.inRoute:
        return Icons.play_circle_fill;
      case TruckOperationalState.stopped:
        return Icons.pause_circle_filled;
      case TruckOperationalState.disconnected:
      case null:
        return Icons.power_off;
    }
  }

  double get displaySpeed => _truck?.displaySpeedKmh ?? 0.0;
  bool get hasPosition => _truck?.hasPosition ?? false;
  double? get lat => _truck?.lat;
  double? get lng => _truck?.lng;
  String get lastUpdate => _truck?.formattedLastUpdate ?? 'Sin registros';

  Future<void> refreshTruckData() async {
    final currentId = _truck?.id;
    if (currentId == null || currentId.isEmpty) return;

    isRefreshing = true;
    notifyListeners();

    try {
      final res = await TravelApi.get('/fleet/trucks');
      final data = (res['data'] as Map<String, dynamic>?) ?? {};
      final list = (data['trucks'] as List<dynamic>?) ?? [];
      final updated = list
          .whereType< Map< String, dynamic > >()
          .map(Truck.fromJson)
          .where((t) => t.id == currentId)
          .firstOrNull;

      if (updated != null) {
        _truck = updated;
      }
    } catch (_) {
      // Mantiene los últimos datos cargados si falla la red
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<String?> callDriver() async {
    final raw = _truck?.driverPhone?.trim();
    if (raw == null || raw.isEmpty) {
      return 'El conductor no tiene un teléfono registrado.';
    }

    final clean = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: clean);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return 'No se pudo abrir la aplicación de llamadas.';
    }
    return null;
  }

  Future<String?> openWhatsApp() async {
    final raw = _truck?.driverPhone?.trim();
    if (raw == null || raw.isEmpty) {
      return 'El conductor no tiene un teléfono registrado.';
    }

    // wa.me requiere solo dígitos con código de país (ej: 56912345678)
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return 'El número de teléfono del conductor no es válido.';
    }

    final uri = Uri.parse('https://wa.me/$digitsOnly');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return 'No se pudo abrir WhatsApp en este dispositivo.';
    }
    return null;
  }
}