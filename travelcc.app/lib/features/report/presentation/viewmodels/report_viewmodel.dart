import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/network/travel_api.dart';

class ReportViewModel extends ChangeNotifier {
  bool _isReporting = false;
  String? _errorMessage;

  bool get isReporting => _isReporting;
  String? get errorMessage => _errorMessage;

  Future<bool> reportIncident(String typeCode) async {
    _isReporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Activa el GPS para enviar la ubicación del reporte.';
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _errorMessage = 'Sin permiso de ubicación para registrar el reporte.';
        return false;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await TravelApi.post('/reports', {
        'type': typeCode,
        'lat': pos.latitude,
        'lng': pos.longitude,
      });

      return true;
    } on TravelApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo obtener tu ubicación o conectar al servidor.';
      return false;
    } finally {
      _isReporting = false;
      notifyListeners();
    }
  }
}