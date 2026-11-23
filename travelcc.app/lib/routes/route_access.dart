import '../core/models/user_profile.dart';

/// Qué pantallas puede abrir cada rol.
///
/// OJO: esto solo ordena la navegación. La seguridad real está en el backend,
/// que responde 403 a lo que no corresponda aunque alguien llegue a la pantalla.
class RouteAccess {
  RouteAccess._();

  static const String login = '/login';
  static const String register = '/register';
  static const String adminHome = '/dashboard'; // jefe de flota
  static const String driverHome = '/map'; // conductor

  // Se pueden abrir sin sesión.
  static const Set<String> _publicRoutes = {login, register};

  // Solo jefe de flota.
  static const Set<String> _adminOnly = {
    '/dashboard',
    '/fleet',
    '/truck-detail',
    '/company-menu',
  };

  // Solo conductor.
  static const Set<String> _driverOnly = {
    '/map',
    '/vehicle',
    '/route-calculation',
    '/route-alert',
    '/active-route',
    '/no-route',
    '/report',
    '/driver-menu',
    '/gps-disabled',
    '/stops',
  };

  // El resto (/profile, /settings, /no-connection, /empty-state) las abren ambos roles.

  static bool isPublic(String location) => _publicRoutes.contains(location);

  static String homeFor(UserProfile profile) =>
      profile.isAdmin ? adminHome : driverHome;

  static bool canAccess(UserProfile profile, String location) {
    if (_adminOnly.contains(location)) return profile.isAdmin;
    if (_driverOnly.contains(location)) return profile.isDriver;
    return true;
  }
}
