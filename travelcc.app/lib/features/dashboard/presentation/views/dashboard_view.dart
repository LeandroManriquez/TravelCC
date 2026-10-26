import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/dashboard_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('TRAVEL CC', style: AppTypography.headlineMedium),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.textMuted),
              onPressed: () => context.goNamed('login'),
            ),
          ],
        ),
        body: Consumer<DashboardViewModel>(
          builder: (context, vm, child) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de Flota',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Tarjetas de estadísticas
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Camiones Activos',
                          '${vm.activeTrucks}',
                          Icons.local_shipping,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          'Alertas',
                          '${vm.pendingAlerts}',
                          Icons.warning_amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildStatCard(
                    'Rutas Completadas',
                    '${vm.completedRoutes}%',
                    Icons.check_circle,
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  const Text(
                    'Accesos Rápidos',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Botón 1: Ver Mapa en Vivo (ESTE ES EL QUE NAVEGA AL MAPA)
                  _buildMenuButton(
                    'Ver Mapa en Vivo',
                    Icons.map,
                    onPressed: () =>
                        context.goNamed('map'), // ← AQUÍ ESTÁ LA MAGIA
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Botón 2: Gestión de Conductores (aún no hace nada)
                  _buildMenuButton(
                    'Gestión de Conductores',
                    Icons.people,
                    onPressed: () {
                      debugPrint('Navegando a Gestión de Conductores...');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget reutilizable para las tarjetas (Aplicando DRY)
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para los botones del menú (Aplicando DRY)
  Widget _buildMenuButton(
    String text,
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed, // ← Aquí recibe la acción desde arriba
        icon: Icon(icon, color: AppColors.primary),
        label: Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.buttonSmallBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
        ),
      ),
    );
  }
}
