import 'package:flutter/material.dart';

class ReportViewModel extends ChangeNotifier {
  bool _isReporting = false;
  bool get isReporting => _isReporting;

  void reportIncident(String type) {
    _isReporting = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      _isReporting = false;
      notifyListeners();
      debugPrint('Reporte enviado: $type');
    });
  }
}
