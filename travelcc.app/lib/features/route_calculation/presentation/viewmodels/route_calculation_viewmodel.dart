import 'package:flutter/material.dart';

class RouteCalculationViewModel extends ChangeNotifier {
  double _progress = 0;
  double get progress => _progress;

  final String vehicleId = 'FH 540';
  final String vehicleModel = 'Volvo 6x4';
  final String weight = '45 T';
  final String height = '4.20 m';

  bool _isCalculating = true;
  bool get isCalculating => _isCalculating;

  void startCalculation() {
    _isCalculating = true;
    _progress = 0;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 100), () {
      _simulateProgress();
    });
  }

  void _simulateProgress() {
    if (_progress < 96) {
      _progress += 2;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 100), () {
        _simulateProgress();
      });
    } else {
      _isCalculating = false;
      notifyListeners();
    }
  }

  void cancelCalculation() {
    _isCalculating = false;
    notifyListeners();
    debugPrint('❌ Cálculo cancelado');
  }
}
