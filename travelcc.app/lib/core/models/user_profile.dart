/// Datos del usuario logueado, tal como los entrega GET /me del backend.

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class FleetInfo {
  final String id;
  final String name;

  /// 'active' o 'inactive'. Solo viene para jefes de flota (admin).
  final String? planStatus;

  const FleetInfo({required this.id, required this.name, this.planStatus});

  bool get isPlanActive => planStatus == 'active';

  factory FleetInfo.fromJson(Map<String, dynamic> json) {
    return FleetInfo(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? '',
      planStatus: json['plan_status'] as String?,
    );
  }
}

class TruckInfo {
  final String id;
  final String plate;
  final double? heightMeters;
  final double? weightTons;

  const TruckInfo({
    required this.id,
    required this.plate,
    this.heightMeters,
    this.weightTons,
  });

  factory TruckInfo.fromJson(Map<String, dynamic> json) {
    return TruckInfo(
      id: json['id'] as String,
      plate: (json['plate'] as String?) ?? '',
      heightMeters: _toDouble(json['height_meters']),
      weightTons: _toDouble(json['weight_tons']),
    );
  }
}

class UserProfile {
  static const String roleAdmin = 'admin'; // jefe de flota
  static const String roleDriver = 'driver'; // conductor

  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? fleetId;
  final FleetInfo? fleet;

  /// Solo los conductores traen su camión (uno por conductor).
  final List<TruckInfo> trucks;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.fleetId,
    this.fleet,
    this.trucks = const [],
  });

  bool get isAdmin => role == roleAdmin;
  bool get isDriver => role == roleDriver;
  bool get hasValidRole => isAdmin || isDriver;

  TruckInfo? get truck => trucks.isEmpty ? null : trucks.first;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final fleetJson = json['fleet'];
    final trucksJson = json['trucks'];

    return UserProfile(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      fleetId: json['fleet_id'] as String?,
      fleet: fleetJson is Map<String, dynamic>
          ? FleetInfo.fromJson(fleetJson)
          : null,
      trucks: trucksJson is List
          ? trucksJson
              .whereType<Map<String, dynamic>>()
              .map(TruckInfo.fromJson)
              .toList()
          : const [],
    );
  }
}
