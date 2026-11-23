import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../network/api_client.dart';

/// Quién está usando la app ahora mismo.
///
/// Combina dos cosas:
///  - la sesión de Supabase Auth (el token), que Supabase guarda en el celular, y
///  - el perfil del usuario (rol, flota, camión), que viene de GET /me.
///
/// El router lo escucha: cuando cambia, redirige solo (login <-> pantalla de inicio).
class SessionController extends ChangeNotifier {
  SessionController() {
    // Si la sesión se cierra por cualquier motivo (logout, token vencido), se limpia el perfil.
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.signedOut && _profile != null) {
        _profile = null;
        notifyListeners();
      }
    });
  }

  late final StreamSubscription<AuthState> _authSubscription;

  UserProfile? _profile;
  UserProfile? get profile => _profile;
  bool get isAuthenticated => _profile != null;

  /// Al abrir la app: si Supabase recuerda una sesión, recupera el perfil.
  /// Si no se puede (sin conexión con el backend, cuenta sin perfil...), vuelve al login.
  Future<void> restore() async {
    if (Supabase.instance.client.auth.currentSession == null) return;

    try {
      await refreshProfile();
    } catch (_) {
      await _clearLocalSession();
    }
  }

  /// Inicia sesión con email y contraseña. Lanza AuthException o ApiException si algo falla.
  Future<void> signIn(String email, String password) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    try {
      await refreshProfile();
    } catch (_) {
      // Credenciales correctas pero no se pudo cargar el perfil: no dejamos una sesión a medias.
      await _clearLocalSession();
      rethrow;
    }
  }

  /// Crea una cuenta nueva. El rol ('driver' o 'admin') viaja en los datos del registro,
  /// pero el que manda es el servidor: solo acepta esos dos y nunca deja elegir flota.
  ///
  /// Devuelve true si la cuenta quedó con la sesión iniciada, o false si Supabase exige
  /// confirmar el correo antes de entrar (en ese caso todavía no hay sesión).
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? fleetName,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
        if (fleetName != null && fleetName.isNotEmpty) 'fleet_name': fleetName,
      },
    );

    if (response.session == null) return false;

    try {
      await refreshProfile();
    } on ApiException catch (e) {
      await _clearLocalSession();
      throw ApiException(
        'Tu cuenta se creó, pero no se pudo cargar tu perfil (${e.message}). Intenta iniciar sesión',
        statusCode: e.statusCode,
        code: e.code,
      );
    } catch (_) {
      await _clearLocalSession();
      rethrow;
    }

    return true;
  }

  /// Vuelve a pedir el perfil a GET /me (por ejemplo, después de crear el camión o de pagar el plan).
  Future<void> refreshProfile() async {
    final json = await ApiClient.instance.get('/me');
    final profile = UserProfile.fromJson(json['data'] as Map<String, dynamic>);

    if (!profile.hasValidRole) {
      throw ApiException(
        'Tu cuenta no tiene un rol válido',
        code: 'ERR_INVALID_ROLE',
      );
    }

    _profile = profile;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Aunque falle la red, la sesión local ya no sirve.
    }
    _profile = null;
    notifyListeners();
  }

  Future<void> _clearLocalSession() async {
    try {
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {}
    _profile = null;
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
