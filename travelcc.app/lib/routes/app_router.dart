import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/views/home_view.dart';
import '../features/auth/presentation/views/auth_view.dart';
import '../features/dashboard/presentation/views/dashboard_view.dart';
import '../features/map/presentation/views/map_view.dart'; // <-- Nuevo

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeView(),
    ),
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
    ), // <-- Nuevo
  ],
);
