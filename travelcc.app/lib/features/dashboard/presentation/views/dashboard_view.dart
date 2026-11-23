import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../company_menu/presentation/views/company_menu_view.dart';
import '../viewmodels/dashboard_viewmodel.dart';

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
          titleSpacing: AppSpacing.md,
          title: const Text(
            'TRAVEL CC',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            Consumer<DashboardViewModel>(
              builder: (context, vm, _) => IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: AppColors.textPrimary,
                ),
                tooltip: 'Actualizar',
                onPressed: vm.isLoading ? null : vm.loadDashboard,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Menú Empresa',
              onPressed: () => context.goNamed('companyMenu'),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          child: Consumer<DashboardViewModel>(
            builder: (context, vm, child) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: vm.loadDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.fleetName,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Resumen de Flota',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      if (vm.errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.criticalRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                            border: Border.all(color: AppColors.criticalRed),
                          ),
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      if (!vm.isLoading && !vm.isPlanActive) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.warningYellow.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                            border: Border.all(color: AppColors.warningYellow),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    color: AppColors.warningYellow,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'PLAN DE FLOTA INACTIVO',
                                      style: TextStyle(
                                        color: AppColors.warningYellow,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Activa el plan corporativo para enlazar conductores y ver camiones en tiempo real.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final ok = await vm.activateDemoPlan();
                                    if (ok && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Plan corporativo activado (Modo Demo)',
                                          ),
                                          backgroundColor: AppColors.successGreen,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Activar Plan (Simulación Demo)',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      if (vm.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Camiones en Flota',
                                '${vm.totalTrucks}',
                                Icons.local_shipping,
                                AppColors.secondary,
                                () => context.goNamed('fleet'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildStatCard(
                                'En Ruta (Activos)',
                                '${vm.activeTrucks}',
                                Icons.gps_fixed,
                                AppColors.success,
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const FleetMonitoringView(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Actividad GPS',
                                '${vm.availabilityPercent.toStringAsFixed(0)}%',
                                Icons.check_circle_outline,
                                AppColors.primary,
                                null,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildStatCard(
                                'Estado Plan',
                                vm.isPlanActive ? 'ACTIVO' : 'INACTIVO',
                                Icons.verified,
                                vm.isPlanActive
                                    ? AppColors.successGreen
                                    : AppColors.warningYellow,
                                () => context.goNamed('companyMenu'),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xxl),
                      const Text(
                        'Accesos Rápidos',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FleetMonitoringView(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.map, color: Colors.white),
                          label: const Text(
                            'Ver Mapa en Vivo de la Flota',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.sm),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => context.goNamed('fleet'),
                          icon: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Flota y Enlace de Conductores',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.panel,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.sm),
                              side: const BorderSide(
                                color: AppColors.buttonSmallBorder,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => context.goNamed('companyMenu'),
                          icon: const Icon(
                            Icons.business,
                            color: AppColors.textPrimary,
                          ),
                          label: const Text(
                            'Portal y Menú Empresa',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}