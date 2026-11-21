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
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'TRAVEL CC',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de Flota',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                Consumer<DashboardViewModel>(
                  builder: (context, vm, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Camiones Activos', '${vm.activeTrucks}', Icons.local_shipping, AppColors.success, context, 'fleet'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard('Alertas', '${vm.pendingAlerts}', Icons.warning_amber_rounded, AppColors.primary, context, 'alerts'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Consumer<DashboardViewModel>(
                  builder: (context, vm, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Rutas Completadas', '${vm.completedRoutes}%', Icons.check_circle_outline, AppColors.secondary, context, null),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(child: SizedBox()),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                const Text(
                  'Accesos Rápidos',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => context.goNamed('map'),
                    icon: const Icon(Icons.map, color: Colors.white),
                    label: const Text('Ver Mapa en Vivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.sm)),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => context.goNamed('fleet'),
                    icon: const Icon(Icons.list_alt, color: Colors.white),
                    label: const Text('Gestión de Conductores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.panel,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.sm), side: const BorderSide(color: AppColors.buttonSmallBorder)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, BuildContext context, String? routeName) {
    return GestureDetector(
      onTap: routeName != null ? () => context.goNamed(routeName) : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: AppColors.buttonSmallBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}