import 'package:flutter/material.dart';

import '../../../../core/network/travel_api.dart';

class VehicleViewModel extends ChangeNotifier {
  final TextEditingController plateController = TextEditingController();
  final TextEditingController heightController =
      TextEditingController(text: '4.1');
  final TextEditingController weightController =
      TextEditingController(text: '25.0');
  final TextEditingController widthController =
      TextEditingController(text: '2.6');
  final TextEditingController lengthController =
      TextEditingController(text: '14.0');

  int ejes = 3;
  bool cargaPeligrosa = false;
  bool cargaSobredimensionada = false;
  bool cargaRefrigerada = false;
  bool isLoading = false;

  VehicleViewModel() {
    loadCurrentTruck();
  }

  Future<void> loadCurrentTruck() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await TravelApi.get('/me');
      final data = (res['data'] as Map<String, dynamic>?) ?? {};
      final trucks = (data['trucks'] as List<dynamic>?) ?? [];
      if (trucks.isNotEmpty && trucks.first is Map<String, dynamic>) {
        final t = trucks.first as Map<String, dynamic>;
        plateController.text = t['plate']?.toString() ?? '';
        if (t['height_meters'] != null) {
          heightController.text = t['height_meters'].toString();
        }
        if (t['weight_tons'] != null) {
          weightController.text = t['weight_tons'].toString();
        }
      }
    } catch (_) {
      // Si aún no tiene camión, mantiene valores por defecto
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setEjes(int count) {
    ejes = count;
    notifyListeners();
  }

  void toggleCargaPeligrosa() {
    cargaPeligrosa = !cargaPeligrosa;
    notifyListeners();
  }

  void toggleCargaSobredimensionada() {
    cargaSobredimensionada = !cargaSobredimensionada;
    notifyListeners();
  }

  void toggleCargaRefrigerada() {
    cargaRefrigerada = !cargaRefrigerada;
    notifyListeners();
  }

  Future<String?> saveVehicleDimensions() async {
    final plate = plateController.text.trim().toUpperCase();
    final height = double.tryParse(heightController.text.replaceAll(',', '.'));
    final weight = double.tryParse(weightController.text.replaceAll(',', '.'));

    if (plate.length < 4) {
      return 'Ingresa una patente válida (ej: ABCD-12).';
    }
    if (height == null || height < 1 || height > 6) {
      return 'La altura debe estar entre 1 y 6 metros.';
    }
    if (weight == null || weight < 0.5 || weight > 100) {
      return 'El peso debe estar entre 0.5 y 100 toneladas.';
    }

    isLoading = true;
    notifyListeners();

    try {
      await TravelApi.put('/me/truck', {
        'plate': plate,
        'height_meters': height,
        'weight_tons': weight,
      });
      return null;
    } on TravelApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo guardar el camión.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    plateController.dispose();
    heightController.dispose();
    weightController.dispose();
    widthController.dispose();
    lengthController.dispose();
    super.dispose();
  }
}