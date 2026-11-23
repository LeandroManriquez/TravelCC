import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/session/session_controller.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._session);

  final SessionController _session;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _disposed = false;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Inicia sesión. Si sale bien NO navega: el router detecta la sesión nueva
  /// y manda al jefe al dashboard y al conductor a su mapa.
  Future<void> onLogin() async {
    if (_isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _errorMessage = 'Ingresa un correo electrónico válido';
      notifyListeners();
      return;
    }

    if (password.isEmpty) {
      _errorMessage = 'Ingresa tu contraseña';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _session.signIn(email, password);
    //} on AuthException catch (e) {
      //_errorMessage = _authErrorMessage(e);
    } on AuthException catch (e) {
      _errorMessage = 'DEBUG (${e.statusCode}): ${e.message}';
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'No se pudo iniciar sesión. Intenta de nuevo';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _authErrorMessage(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (message.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión';
    }
    if (message.contains('too many') || message.contains('rate limit')) {
      return 'Demasiados intentos. Espera un momento e intenta de nuevo';
    }
    if (message.contains('socket') ||
        message.contains('host lookup') ||
        message.contains('clientexception') ||
        message.contains('network')) {
      return 'Sin conexión con el servidor de autenticación';
    }
    return 'No se pudo iniciar sesión. Intenta de nuevo';
  }

  // Tras un login exitoso el router cierra esta pantalla; evita avisar a una pantalla ya cerrada.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
