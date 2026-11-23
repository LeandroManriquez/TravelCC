import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/network/api_client.dart';

class TelemetryBatcher {
  final List<Object> _buffer = [];
  Timer? _flushTimer;
  DateTime? _lastBufferedAt;
  LatLng? _lastBufferedPoint;
  bool _isFlushing = false;

  void start() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => flush(),
    );
  }

  void dispose() {
    _flushTimer?.cancel();
    flush();
  }

  void enqueue({
    required String truckId,
    required LatLng point,
    required double speedKmh,
    required double heading,
  }) {
    final now = DateTime.now().toUtc();
    if (_lastBufferedAt != null && _lastBufferedPoint != null) {
      final secondsElapsed = now.difference(_lastBufferedAt!).inSeconds;
      final metersMoved = Geolocator.distanceBetween(
        _lastBufferedPoint!.latitude,
        _lastBufferedPoint!.longitude,
        point.latitude,
        point.longitude,
      );
      if (metersMoved < 10 && secondsElapsed < 60) return;
      if (secondsElapsed < 5) return;
    }

    _lastBufferedAt = now;
    _lastBufferedPoint = point;

    if (_buffer.length >= 100) {
      _buffer.removeAt(0);
    }

    _buffer.add({
      'truck_id': truckId,
      'lat': point.latitude,
      'lng': point.longitude,
      'speed_kmh': double.parse(speedKmh.toStringAsFixed(1)),
      'heading': double.parse(heading.toStringAsFixed(1)),
      'recorded_at': now.toIso8601String(),
    });

    if (_buffer.length >= 5) {
      flush();
    }
  }

  Future<void> flush() async {
    if (_isFlushing || _buffer.isEmpty) return;

    _isFlushing = true;
    final count = _buffer.length > 50 ? 50 : _buffer.length;
    final batch = _buffer.sublist(0, count).toList();

    try {
      await ApiClient.instance.post('/telemetry', batch);
      _buffer.removeRange(0, count);
    } catch (_) {
      // Mantiene los puntos en cola para reintentar al recuperar señal
    } finally {
      _isFlushing = false;
    }
  }
}