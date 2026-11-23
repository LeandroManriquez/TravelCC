import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/user_profile.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/session/session_controller.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel(this._session);

  final SessionController _session;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController fleetNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String _role = UserProfile.roleDriver;
  String get role => _role;
  bool get isAdmin => _role == UserProfile.roleAdmin;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _infoMessage;
  String? get infoMessage => _infoMessage;

  bool _disposed = false;

  void selectRole(String role) {
    if (_isLoading) return;
    _role = role;
    _errorMessage = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  String? _validate() {
    if (fullNameController.text.trim().length < 2) {
      return 'Ingresa tu nombre completo';
    }
    if (isAdmin && fleetNameController.text.trim().length < 2) {
      return 'Ingresa el nombre de tu flota o empresa';
    }
    if (!_emailRegex.hasMatch(emailController.text.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    if (passwordController.text.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (passwordController.text != confirmPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Crea la cuenta. Si sale bien NO navega: el router detecta la sesión nueva
  /// y manda al jefe al dashboard y al conductor a su mapa.
  Future<void> onRegister() async {
    if (_isLoading) return;

    final validationError = _validate();
    if (validationError != null) {
      _errorMessage = validationError;
      _infoMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      final signedIn = await _session.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        role: _role,
        fleetName: isAdmin ? fleetNameController.text.trim() : null,
      );

      if (!signedIn) {
        // Supabase pide confirmar el correo antes de dejar entrar.
        _infoMessage =
            'Cuenta creada. Revisa tu correo para confirmarla y luego inicia sesión.';
        passwordController.clear();
        confirmPasswordController.clear();
      }
    } on AuthException catch (e) {
      _errorMessage = _authErrorMessage(e);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'No se pudo crear la cuenta. Intenta de nuevo';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _authErrorMessage(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('already registered') ||
        message.contains('already been registered') ||
        message.contains('user_already_exists')) {
      return 'Ya existe una cuenta con ese correo. Inicia sesión';
    }
    if (message.contains('password')) {
      return 'La contraseña es muy débil. Usa al menos 8 caracteres, con letras y números';
    }
    if (message.contains('signup') && message.contains('disabled')) {
      return 'El registro de cuentas está desactivado';
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Demasiados intentos. Espera un momento e intenta de nuevo';
    }
    if (message.contains('invalid') && message.contains('email')) {
      return 'El correo electrónico no es válido';
    }
    if (message.contains('socket') ||
        message.contains('host lookup') ||
        message.contains('clientexception') ||
        message.contains('network')) {
      return 'Sin conexión con el servidor de autenticación';
    }
    return 'No se pudo crear la cuenta. Intenta de nuevo';
  }

  // Tras registrarse el router cierra esta pantalla; evita avisar a una pantalla ya cerrada.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    fullNameController.dispose();
    fleetNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
