import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/states_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key});

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
                                  color: AppColors.actionOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'ESTADO DE TELEMETRÍA',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SISTEMA ACTIVO',
                              style: TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
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
                            Icons.local_shipping,
                            color: AppColors.actionOrange,
                            size: 64,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDark,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: AppColors.textMuted,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Sin rutas o camiones registrados',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Añade tus trayectos habituales o registra unidades de tu flota para calcular gálibos, peajes y restricciones de carga en tiempo real.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: vm.addNewUnitOrRoute,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: const Text(
                          'AGREGAR NUEVA UNIDAD O RUTA',
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

                    const SizedBox(height: AppSpacing.xxl),
                    _buildInactiveMetric(
                      'Gálibo Máximo Parametrizado',
                      '-- m',
                      Icons.height,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInactiveMetric(
                      'Restricción Ejes / PBV',
                      '-- Tn',
                      Icons.scale,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInactiveMetric(
                      'Estimación de Peajes Activa',
                      'INACTIVO',
                      Icons.receipt_long,
                      valueColor: AppColors.textMuted,
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

  Widget _buildInactiveMetric(
    String label,
    String value,
    IconData icon, {
    Color valueColor = AppColors.textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
