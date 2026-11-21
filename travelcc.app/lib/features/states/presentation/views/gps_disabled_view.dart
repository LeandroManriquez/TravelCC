import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/states_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class GpsDisabledView extends StatelessWidget {
  const GpsDisabledView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatesViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Consumer<StatesViewModel>(
          builder: (context, vm, child) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.panelDark,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.warningYellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'PROTOCOLO DE SEGURIDAD VIAL',
                                style: TextStyle(
                                  color: AppColors.warningYellow,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'SYS.LOC-04',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    // Icono principal
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.panelDark,
                        borderRadius: BorderRadius.circular(AppSpacing.lg),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.location_off,
                            color: AppColors.warningYellow,
                            size: 64,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDark,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.warningYellow,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Acceso a ubicación desactivado',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'BLOQUEO CRÍTICO DE TELEMETRÍA',
                      style: TextStyle(
                        color: AppColors.warningYellow,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'TravelCC necesita tu ubicación en tiempo real para anticipar puentes bajos, túneles estrechos y básculas activas antes de que llegues a ellos.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        border: Border.all(color: AppColors.buttonSmallBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.actionOrange,
                            size: 28,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AVISO DE CUMPLIMIENTO',
                                  style: TextStyle(
                                    color: AppColors.actionOrange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'La navegación de carga pesada no puede operar sin GPS.',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.panelDark,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'MONITOREO INACTIVO',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.criticalRed.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Fuera de Línea',
                                  style: TextStyle(
                                    color: AppColors.criticalRed,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInactiveStatus(
                                  'Gálibo / Puentes',
                                  'Inactivo',
                                  Icons.height,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _buildInactiveStatus(
                                  'Básculas',
                                  'Inactivo',
                                  Icons.scale,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _buildInactiveStatus(
                                  'Rutas HazMat',
                                  'Inactivo',
                                  Icons.warning_amber_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: vm.activateLocation,
                        icon: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'ACTIVAR UBICACIÓN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.actionOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: vm.showPermissionsGuide,
                        icon: const Icon(
                          Icons.tune,
                          color: AppColors.textPrimary,
                        ),
                        label: const Text(
                          'Cómo otorgar permisos en Ajustes',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.buttonSmallBorder,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    const Text(
                      '© TRAVELCC CAB SAFETY TELEMATICS • V4.2',
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInactiveStatus(String title, String status, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
            textAlign: TextAlign.center,
          ),
          Text(
            status,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
