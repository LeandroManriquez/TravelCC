import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  String _distanceUnit = 'km';
  String get distanceUnit => _distanceUnit;

  String _weightUnit = 't';
  String get weightUnit => _weightUnit;

  String _heightUnit = 'm';
  String get heightUnit => _heightUnit;

  bool _voiceAlerts = true;
  bool get voiceAlerts => _voiceAlerts;

  double _cabinVolume = 85.0;
  double get cabinVolume => _cabinVolume;

  bool _scaleAlerts = true;
  bool get scaleAlerts => _scaleAlerts;

  bool _tollAlerts = true;
  bool get tollAlerts => _tollAlerts;

  bool _bridgeAlerts = true;
  bool get bridgeAlerts => _bridgeAlerts;

  String _mapMode = 'dark';
  String get mapMode => _mapMode;

  void setDistanceUnit(String unit) {
    _distanceUnit = unit;
    notifyListeners();
  }

  void setWeightUnit(String unit) {
    _weightUnit = unit;
    notifyListeners();
  }

  void setHeightUnit(String unit) {
    _heightUnit = unit;
    notifyListeners();
  }

  void toggleVoiceAlerts() {
    _voiceAlerts = !_voiceAlerts;
    notifyListeners();
  }

  void setCabinVolume(double value) {
    _cabinVolume = value;
    notifyListeners();
  }

  void toggleScaleAlerts() {
    _scaleAlerts = !_scaleAlerts;
    notifyListeners();
  }

  void toggleTollAlerts() {
    _tollAlerts = !_tollAlerts;
    notifyListeners();
  }

  void toggleBridgeAlerts() {
    _bridgeAlerts = !_bridgeAlerts;
    notifyListeners();
  }

  void setMapMode(String mode) {
    _mapMode = mode;
    notifyListeners();
  }

  void savePreferences() {
    debugPrint(
      '💾 Preferencias guardadas: $_distanceUnit, $_weightUnit, $_heightUnit',
    );
  }
}
