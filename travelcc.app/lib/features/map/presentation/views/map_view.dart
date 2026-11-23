import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/travel_api.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/map_models.dart';
import '../services/telemetry_batcher.dart';
import '../widgets/map_overlays.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TelemetryBatcher _telemetryBatcher = TelemetryBatcher();
  StreamSubscription<Position>? _positionSubscription;

  LatLng _currentLocation = const LatLng(-33.4489, -70.6693);
  double _currentHeading = 0.0;
  double _currentSpeedKmh = 0.0;
  bool _hasRealLocation = false;
  bool _checkedInitialQuery = false;

  bool _isSearchingPlaces = false;
  bool _isCalculatingRoute = false;
  bool _isNavigating = false;
  bool _followCamera = true;
  List<PlaceSuggestion> _suggestions = [];
  List<LatLng> _routePoints = [];
  LatLng? _destinationPoint;
  PlannedRouteInfo? _plannedRoute;

  List<RoadReport> _reports = [];
  RoadReport? _selectedReport;

  @override
  void initState() {
    super.initState();
    _telemetryBatcher.start();
    _initLocationTracking();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checkedInitialQuery) {
      _checkedInitialQuery = true;
      final reported =
          GoRouterState.of(context).uri.queryParameters['reported'];
      _loadReports(openLatestPopup: reported == '1');
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _telemetryBatcher.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocationTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) context.goNamed('gpsDisabled');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) context.goNamed('gpsDisabled');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) context.goNamed('gpsDisabled');
      return;
    }

    final currentPos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    _handleNewPosition(currentPos, forceCameraMove: true);

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) => _handleNewPosition(pos));
  }

  void _handleNewPosition(Position pos, {bool forceCameraMove = false}) {
    if (!mounted) return;
    final newLatLng = LatLng(pos.latitude, pos.longitude);
    final speedKmh = pos.speed > 0 ? pos.speed * 3.6 : 0.0;
    final heading = pos.heading >= 0 ? pos.heading : _currentHeading;

    setState(() {
      _currentLocation = newLatLng;
      _currentSpeedKmh = speedKmh;
      _currentHeading = heading;
      _hasRealLocation = true;
    });

    final truck = context.read<SessionController>().profile?.truck;
    if (truck != null) {
      _telemetryBatcher.enqueue(
        truckId: truck.id,
        point: newLatLng,
        speedKmh: speedKmh,
        heading: heading,
      );
    }

    if (_isNavigating && _followCamera) {
      final rotation = speedKmh > 3.0 ? -heading : 0.0;
      _mapController.moveAndRotate(newLatLng, 17.8, rotation);
    } else if (forceCameraMove || (_routePoints.isEmpty && _followCamera)) {
      _mapController.move(newLatLng, 15.0);
    }
  }

  Future<void> _loadReports({bool openLatestPopup = false}) async {
    try {
      final res = await TravelApi.get('/reports');
      final rawList = (res['data'] as List<dynamic>?) ?? [];
      final List<RoadReport> parsed = [];
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          final report = RoadReport.fromJson(item);
          if (report.lat != null && report.lng != null) {
            parsed.add(report);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _reports = parsed;
        if (openLatestPopup && parsed.isNotEmpty) {
          _selectedReport = parsed.first;
        }
      });

      if (openLatestPopup && parsed.isNotEmpty) {
        _mapController.move(
          LatLng(parsed.first.lat!, parsed.first.lng!),
          15.5,
        );
      }
    } catch (_) {}
  }

  Future<void> _searchDestinationPlaces() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearchingPlaces = true;
      _suggestions = [];
      _selectedReport = null;
    });

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '4',
        'countrycodes': 'cl',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'TravelCC-App/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<PlaceSuggestion> results = [];
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final place = PlaceSuggestion.fromJson(item);
              if (place.lat != null && place.lng != null) {
                results.add(place);
              }
            }
          }
        }

        if (results.isEmpty) {
          _showSnack(
            'No se encontraron lugares para "$query".',
            AppColors.panelDark,
          );
        } else {
          setState(() => _suggestions = results);
        }
      } else {
        _showSnack(
          'Error al buscar dirección (${response.statusCode}).',
          AppColors.criticalRed,
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnack('Error de red al buscar destino.', AppColors.criticalRed);
      }
    } finally {
      if (mounted) setState(() => _isSearchingPlaces = false);
    }
  }

  Future<void> _planRouteTo(PlaceSuggestion place) async {
    final session = context.read<SessionController>();
    var truck = session.profile?.truck;

    if (truck == null) {
      await session.refreshProfile();
      truck = session.profile?.truck;
    }

    if (!mounted) return;

    if (truck == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Configura primero tu camión en el ícono naranja.',
          ),
          backgroundColor: AppColors.criticalRed,
          action: SnackBarAction(
            label: 'Configurar',
            textColor: Colors.white,
            onPressed: () => context.goNamed('vehicle'),
          ),
        ),
      );
      return;
    }

    final activeTruck = truck;

    setState(() {
      _suggestions = [];
      _isCalculatingRoute = true;
      _isNavigating = false;
      _searchController.text = place.shortName;
    });

    try {
      final res = await TravelApi.post('/routes/plan', {
        'truck_id': activeTruck.id,
        'origin': {
          'lat': _currentLocation.latitude,
          'lng': _currentLocation.longitude,
        },
        'destination': {
          'lat': place.lat!,
          'lng': place.lng!,
        },
      });

      final data = (res['data'] as Map<String, dynamic>?) ?? {};
      final recommended =
          (data['recommended_route'] as Map<String, dynamic>?) ?? {};
      final geometry =
          (recommended['geometry'] as Map<String, dynamic>?) ?? {};
      final coordsRaw = (geometry['coordinates'] as List<dynamic>?) ?? [];

      final List<LatLng> points = [];
      for (final c in coordsRaw) {
        if (c is List && c.length >= 2 && c[0] is num && c[1] is num) {
          points.add(
            LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
          );
        }
      }

      final summary =
          (recommended['restrictions_summary'] as Map<String, dynamic>?) ?? {};
      final restrictionsRaw =
          (recommended['restrictions'] as List<dynamic>?) ?? [];
      final firstRestrictionDesc = restrictionsRaw.isNotEmpty &&
              restrictionsRaw.first is Map<String, dynamic>
          ? (restrictionsRaw.first as Map<String, dynamic>)['description']
              ?.toString()
          : null;

      final destLatLng = LatLng(place.lat!, place.lng!);

      if (!mounted) return;
      setState(() {
        _routePoints = points;
        _destinationPoint = destLatLng;
        _plannedRoute = PlannedRouteInfo(
          destinationName: place.shortName,
          distanceKm:
              ((recommended['distance_meters'] as num?)?.toDouble() ?? 0) /
                  1000.0,
          durationMinutes:
              (((recommended['duration_seconds'] as num?)?.toDouble() ?? 0) /
                      60.0)
                  .round(),
          isCompatible: recommended['is_compatible'] == true,
          blockingCount: (summary['blocking_count'] as num?)?.toInt() ?? 0,
          warningCount: (summary['warning_count'] as num?)?.toInt() ?? 0,
          firstRestrictionDesc: firstRestrictionDesc,
          truckPlate: activeTruck.plate,
        );
      });

      if (points.length >= 2) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: const EdgeInsets.fromLTRB(40, 110, 40, 300),
          ),
        );
      } else {
        _mapController.move(destLatLng, 13.0);
      }
    } on TravelApiException catch (e) {
      if (mounted) _showSnack(e.message, AppColors.criticalRed);
    } catch (_) {
      if (mounted) {
        _showSnack('No se pudo calcular la ruta.', AppColors.criticalRed);
      }
    } finally {
      if (mounted) setState(() => _isCalculatingRoute = false);
    }
  }

  void _startNavigation() {
    if (_plannedRoute == null) return;
    setState(() {
      _isNavigating = true;
      _followCamera = true;
      _selectedReport = null;
      _suggestions = [];
    });
    final rotation = _currentSpeedKmh > 3.0 ? -_currentHeading : 0.0;
    _mapController.moveAndRotate(_currentLocation, 17.8, rotation);
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
      _followCamera = true;
    });
    _mapController.moveAndRotate(_currentLocation, 15.0, 0.0);
  }

  void _clearRoute() {
    setState(() {
      _isNavigating = false;
      _followCamera = true;
      _routePoints = [];
      _destinationPoint = null;
      _plannedRoute = null;
      _suggestions = [];
      _searchController.clear();
    });
    _mapController.moveAndRotate(_currentLocation, 15.0, 0.0);
  }

  double get _liveRemainingKm {
    if (_destinationPoint == null) return _plannedRoute?.distanceKm ?? 0;
    final meters = Geolocator.distanceBetween(
      _currentLocation.latitude,
      _currentLocation.longitude,
      _destinationPoint!.latitude,
      _destinationPoint!.longitude,
    );
    return (meters * 1.25) / 1000.0;
  }

  int get _liveRemainingMinutes {
    final km = _liveRemainingKm;
    final avgSpeed = _currentSpeedKmh > 15.0 ? _currentSpeedKmh : 55.0;
    return ((km / avgSpeed) * 60).round().clamp(1, 999);
  }

  void _showSnack(String text, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          Positioned.fill(child: _buildMapLayer()),
          if (_isNavigating && _plannedRoute != null)
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: ActiveNavTopBanner(
                route: _plannedRoute!,
                speedKmh: _currentSpeedKmh,
              ),
            )
          else
            _buildNormalTopIcons(),
          if (_selectedReport != null)
            Positioned(
              top: _isNavigating ? 145 : 105,
              left: 16,
              right: 16,
              child: ReportPopupCard(
                report: _selectedReport!,
                onClose: () => setState(() => _selectedReport = null),
              ),
            ),
          ..._buildRightButtons(),
          if (_isNavigating && _plannedRoute != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: ActiveNavBottomBar(
                remainingMinutes: _liveRemainingMinutes,
                remainingKm: _liveRemainingKm,
                onStop: _stopNavigation,
              ),
            )
          else ...[
            if (_suggestions.isNotEmpty)
              _buildSuggestionsList()
            else if (_plannedRoute != null)
              Positioned(
                bottom: 168,
                left: 16,
                right: 16,
                child: RoutePreviewCard(
                  route: _plannedRoute!,
                  onStartNavigation: _startNavigation,
                  onClear: _clearRoute,
                ),
              ),
            _buildBottomSearchBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildMapLayer() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: 15.0,
        onPositionChanged: (_, hasGesture) {
          if (hasGesture && _followCamera) {
            setState(() => _followCamera = false);
          }
        },
        onTap: (_, __) {
          if (_selectedReport != null || _suggestions.isNotEmpty) {
            setState(() {
              _selectedReport = null;
              _suggestions = [];
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.travelcc.app',
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: _isNavigating ? 10.0 : 8.0,
                color: Colors.black54,
              ),
              Polyline(
                points: _routePoints,
                strokeWidth: _isNavigating ? 7.0 : 5.5,
                color: (_plannedRoute?.isCompatible ?? true)
                    ? AppColors.actionOrange
                    : AppColors.criticalRed,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            ..._reports.map((report) {
              final isSelected = _selectedReport?.id == report.id;
              return Marker(
                point: LatLng(report.lat!, report.lng!),
                width: isSelected ? 48 : 40,
                height: isSelected ? 48 : 40,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedReport = report;
                      _suggestions = [];
                    });
                    _mapController.move(
                      LatLng(report.lat!, report.lng!),
                      16.5,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: report.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: isSelected ? 3.5 : 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      report.icon,
                      color: Colors.white,
                      size: isSelected ? 24 : 20,
                    ),
                  ),
                ),
              );
            }),
            if (_destinationPoint != null)
              Marker(
                point: _destinationPoint!,
                width: 46,
                height: 46,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            Marker(
              point: _currentLocation,
              width: _isNavigating ? 76 : 52,
              height: _isNavigating ? 76 : 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isNavigating)
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: AppColors.actionOrange.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.actionOrange.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                    ),
                  Container(
                    width: _isNavigating ? 48 : 44,
                    height: _isNavigating ? 48 : 44,
                    decoration: BoxDecoration(
                      color: _hasRealLocation
                          ? AppColors.actionOrange
                          : AppColors.textMuted,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isNavigating
                          ? Icons.navigation_rounded
                          : Icons.local_shipping,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNormalTopIcons() {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.goNamed('driverMenu'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.panelDark,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4)],
              ),
              child: const Icon(Icons.person, color: AppColors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: () => context.goNamed('vehicle'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.panelDark,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4)],
              ),
              child: const Icon(
                Icons.local_shipping,
                color: AppColors.actionOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRightButtons() {
    return [
      Positioned(
        bottom: _isNavigating ? 245 : 325,
        right: 16,
        child: FloatingActionButton.small(
          heroTag: 'refresh_reports',
          onPressed: () {
            _loadReports();
            _showSnack('Reportes actualizados', AppColors.panelDark);
          },
          backgroundColor: AppColors.panelDark,
          child: const Icon(Icons.refresh, color: AppColors.textPrimary),
        ),
      ),
      Positioned(
        bottom: _isNavigating ? 193 : 273,
        right: 16,
        child: FloatingActionButton.small(
          heroTag: 'recenter_gps',
          onPressed: () {
            setState(() => _followCamera = true);
            if (_isNavigating) {
              final rotation =
                  _currentSpeedKmh > 3.0 ? -_currentHeading : 0.0;
              _mapController.moveAndRotate(_currentLocation, 17.8, rotation);
            } else {
              _mapController.moveAndRotate(_currentLocation, 15.5, 0.0);
            }
          },
          backgroundColor:
              !_followCamera ? AppColors.actionOrange : AppColors.panelDark,
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
      ),
      Positioned(
        bottom: _isNavigating ? 125 : 205,
        right: 16,
        child: FloatingActionButton(
          heroTag: 'report_incident',
          onPressed: () => context.goNamed('report'),
          backgroundColor: AppColors.criticalRed,
          elevation: 4,
          child: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    ];
  }

  Widget _buildSuggestionsList() {
    return Positioned(
      bottom: 168,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panelDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.buttonSmallBorder),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _suggestions.map((place) {
            return ListTile(
              dense: true,
              leading: const Icon(
                Icons.place,
                color: AppColors.actionOrange,
                size: 20,
              ),
              title: Text(
                place.shortName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                place.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              onTap: () => _planRouteTo(place),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomSearchBar() {
    return Positioned(
      bottom: 96,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.panelDark,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: AppColors.buttonSmallBorder),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchDestinationPlaces(),
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Buscar destino (ej: Valparaíso, Ruta 68)...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_isSearchingPlaces || _isCalculatingRoute)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.actionOrange,
                ),
              )
            else ...[
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  onPressed: _clearRoute,
                ),
              IconButton(
                icon: const Icon(
                  Icons.directions,
                  color: AppColors.actionOrange,
                ),
                tooltip: 'Calcular ruta',
                onPressed: _searchDestinationPlaces,
              ),
            ],
            IconButton(
              icon: const Icon(
                Icons.star_border,
                color: AppColors.warningYellow,
              ),
              tooltip: 'Paradas',
              onPressed: () => context.goNamed('stops'),
            ),
          ],
        ),
      ),
    );
  }
}