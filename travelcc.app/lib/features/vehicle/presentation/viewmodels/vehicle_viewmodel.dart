import 'package:flutter/material.dart';

class VehicleViewModel extends ChangeNotifier {
  final TextEditingController heightController = TextEditingController(
    text: '4.2',
  );
  final TextEditingController weightController = TextEditingController(
    text: '25',
  );
  final TextEditingController widthController = TextEditingController(
    text: '2.5',
  );
  final TextEditingController lengthController = TextEditingController(
    text: '12.5',
  );

  int _ejes = 4;
  int get ejes => _ejes;

  bool _cargaPeligrosa = false;
  bool get cargaPeligrosa => _cargaPeligrosa;

  bool _cargaSobredimensionada = false;
  bool get cargaSobredimensionada => _cargaSobredimensionada;

  bool _cargaRefrigerada = false;
  bool get cargaRefrigerada => _cargaRefrigerada;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setEjes(int value) {
    _ejes = value;
    notifyListeners();
  }

  void toggleCargaPeligrosa() {
    _cargaPeligrosa = !_cargaPeligrosa;
    notifyListeners();
  }

  void toggleCargaSobredimensionada() {
    _cargaSobredimensionada = !_cargaSobredimensionada;
    notifyListeners();
  }

  void toggleCargaRefrigerada() {
    _cargaRefrigerada = !_cargaRefrigerada;
    notifyListeners();
  }

  Future<void> saveVehicleDimensions() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
    debugPrint(
      '✅ Camión guardado: Alto ${heightController.text}m, Peso ${weightController.text}t, Ejes: $ejes',
    );
  }
}
