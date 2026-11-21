import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedRole = 'usuario'; // 'usuario' o 'empresa'
  String get selectedRole => _selectedRole;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  void selectRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  Future<void> onLogin() async {
    _isLoading = true;
    notifyListeners();

    // Simulación de carga de red
    await Future.delayed(const Duration(milliseconds: 1500));

    _isLoading = false;
    notifyListeners();
  }
}
