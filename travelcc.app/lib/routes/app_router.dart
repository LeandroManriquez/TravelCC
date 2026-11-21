import 'package:go_router/go_router.dart';

import '../features/auth/presentation/views/auth_view.dart';
import '../features/dashboard/presentation/views/dashboard_view.dart';
import '../features/map/presentation/views/map_view.dart';
import '../features/fleet/presentation/views/fleet_view.dart';
import '../features/report/presentation/views/report_view.dart';
import '../features/vehicle/presentation/views/vehicle_view.dart';
import '../features/truck_detail/presentation/views/truck_detail_view.dart';
import '../features/settings/presentation/views/settings_view.dart';
import '../features/route_alert/presentation/views/route_alert_view.dart';
import '../features/route_calculation/presentation/views/route_calculation_view.dart';
import '../features/active_route/presentation/views/active_route_view.dart';
import '../features/company_menu/presentation/views/company_menu_view.dart';
import '../features/driver_menu/presentation/views/driver_menu_view.dart';
import '../features/no_route/presentation/views/no_route_view.dart';
import '../features/profile/presentation/views/profile_view.dart';
import '../features/states/presentation/views/gps_disabled_view.dart';
import '../features/states/presentation/views/no_connection_view.dart';
import '../features/states/presentation/views/empty_state_view.dart';
import '../features/states/presentation/views/stops_explorer_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const AuthView(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) => const MapView(),
    ),
    GoRoute(
      path: '/fleet',
      name: 'fleet',
      builder: (context, state) => const FleetView(),
    ),
    GoRoute(
      path: '/report',
      name: 'report',
      builder: (context, state) => const ReportView(),
    ),
    GoRoute(
      path: '/vehicle',
      name: 'vehicle',
      builder: (context, state) => const VehicleView(),
    ),
    GoRoute(
      path: '/truck-detail',
      name: 'truckDetail',
      builder: (context, state) => const TruckDetailView(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsView(),
    ),
    GoRoute(
      path: '/route-alert',
      name: 'routeAlert',
      builder: (context, state) => const RouteAlertView(),
    ),
    GoRoute(
      path: '/route-calculation',
      name: 'routeCalculation',
      builder: (context, state) => const RouteCalculationView(),
    ),
    GoRoute(
      path: '/active-route',
      name: 'activeRoute',
      builder: (context, state) => const ActiveRouteView(),
    ),
    GoRoute(
      path: '/company-menu',
      name: 'companyMenu',
      builder: (context, state) => const CompanyMenuView(),
    ),
    GoRoute(
      path: '/driver-menu',
      name: 'driverMenu',
      builder: (context, state) => const DriverMenuView(),
    ),
    GoRoute(
      path: '/no-route',
      name: 'noRoute',
      builder: (context, state) => const NoRouteView(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileView(),
    ),
    GoRoute(
      path: '/gps-disabled',
      name: 'gpsDisabled',
      builder: (context, state) => const GpsDisabledView(),
    ),
    GoRoute(
      path: '/no-connection',
      name: 'noConnection',
      builder: (context, state) => const NoConnectionView(),
    ),
    GoRoute(
      path: '/empty-state',
      name: 'emptyState',
      builder: (context, state) => const EmptyStateView(),
    ),
    GoRoute(
      path: '/stops',
      name: 'stops',
      builder: (context, state) => const StopsExplorerView(),
    ),
  ],
);
