import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PlaceSuggestion {
  final String displayName;
  final String shortName;
  final double? lat;
  final double? lng;

  const PlaceSuggestion({
    required this.displayName,
    required this.shortName,
    required this.lat,
    required this.lng,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final full = json['display_name']?.toString() ?? 'Destino';
    final parts = full.split(',');
    final short = parts.take(2).join(',').trim();
    return PlaceSuggestion(
      displayName: full,
      shortName: short.isEmpty ? full : short,
      lat: double.tryParse(json['lat']?.toString() ?? ''),
      lng: double.tryParse(json['lon']?.toString() ?? ''),
    );
  }
}

class PlannedRouteInfo {
  final String destinationName;
  final double distanceKm;
  final int durationMinutes;
  final bool isCompatible;
  final int blockingCount;
  final int warningCount;
  final String? firstRestrictionDesc;
  final String truckPlate;

  const PlannedRouteInfo({
    required this.destinationName,
    required this.distanceKm,
    required this.durationMinutes,
    required this.isCompatible,
    required this.blockingCount,
    required this.warningCount,
    required this.firstRestrictionDesc,
    required this.truckPlate,
  });
}

class RoadReport {
  final String id;
  final String type;
  final String? description;
  final double? lat;
  final double? lng;
  final DateTime? createdAt;

  const RoadReport({
    required this.id,
    required this.type,
    this.description,
    this.lat,
    this.lng,
    this.createdAt,
  });

  factory RoadReport.fromJson(Map<String, dynamic> json) {
    return RoadReport(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'accident',
      description: json['description']?.toString(),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  String get title {
    switch (type) {
      case 'accident':
        return 'Accidente / Choque';
      case 'roadworks':
        return 'Obras en la vía';
      case 'low_bridge':
        return 'Puente o paso bajo';
      case 'heavy_traffic':
        return 'Tráfico intenso';
      default:
        return 'Incidencia vial';
    }
  }

  IconData get icon {
    switch (type) {
      case 'accident':
        return Icons.car_crash;
      case 'roadworks':
        return Icons.construction;
      case 'low_bridge':
        return Icons.height;
      case 'heavy_traffic':
        return Icons.traffic;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color get color {
    switch (type) {
      case 'accident':
        return AppColors.criticalRed;
      case 'roadworks':
        return AppColors.actionOrange;
      case 'low_bridge':
        return Colors.blue;
      case 'heavy_traffic':
        return AppColors.warningYellow;
      default:
        return AppColors.criticalRed;
    }
  }

  String get timeAgoText {
    if (createdAt == null) return 'Reciente';
    final diff = DateTime.now().toUtc().difference(createdAt!.toUtc());
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    return 'Hace ${diff.inHours} h';
  }
}