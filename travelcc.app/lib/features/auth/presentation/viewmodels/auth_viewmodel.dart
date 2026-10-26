import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> onLogin() async {
    _isLoading = true;
    notifyListeners();

    // Simulamos la espera del Backend (1.5 segundos)
    await Future.delayed(const Duration(milliseconds: 1500));

    _isLoading = false;
    notifyListeners();

    // Aquí en el futuro validaremos con el Backend real
    debugPrint('Login simulado exitoso');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
