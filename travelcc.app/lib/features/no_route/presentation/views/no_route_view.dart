import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/no_route_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class NoRouteView extends StatelessWidget {
  const NoRouteView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoRouteViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Consumer<NoRouteViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Header rojo
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.criticalRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: Border.all(
                        color: AppColors.criticalRed,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.criticalRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.criticalRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'BLOQUEO DE TRAZADO CRÍTICO',
                                    style: TextStyle(
                                      color: AppColors.criticalRed,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ninguna ruta compatible con tu camión',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  // Imagen placeholder
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  // Parámetros del camión
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildParam(Icons.height, 'H: ${vm.truckHeight} m'),
                        const Text(
                          '|',
                          style: TextStyle(color: AppColors.textDisabled),
                        ),
                        _buildParam(Icons.straighten, 'W: ${vm.truckWeight} T'),
                        const Text(
                          '|',
                          style: TextStyle(color: AppColors.textDisabled),
                        ),
                        _buildParam(
                          Icons.warning_amber_rounded,
                          'HazMat ${vm.hazmatClass}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Todas las vías disponibles hacia el destino superan los límites de peso estructural (45 Ton) o presentan pasos con gálibo inferior a tu altura registrada (4.20 m).',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'OBSTÁCULOS DETECTADOS EN EL CORREDOR',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildObstacleCard(
                    vm.bridgeName,
                    'Gálibo Máximo: ${vm.bridgeMaxHeight} m (Déficit: ${vm.heightDeficit} m)',
                    'INFRANQUEABLE',
                    AppColors.criticalRed,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildObstacleCard(
                    vm.passName,
                    'Prohibición transporte Carga Peligrosa',
                    'RESTRICCIÓN',
                    AppColors.warningYellow,
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.panelDark,
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'LÍMITE VÍA',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '${vm.routeLimit} Ton',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.panelDark,
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TU REGISTRO',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '${vm.truckWeight} Ton',
                                style: const TextStyle(
                                  color: AppColors.criticalRed,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        vm.adjustParameters();
                        context.goNamed('vehicle');
                      },
                      icon: const Icon(Icons.tune, color: Colors.white),
                      label: const Text(
                        'Ajustar Parámetros del Camión',
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
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: vm.contactSupport,
                      icon: const Icon(
                        Icons.headset_mic,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'Contactar Soporte Logístico',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.buttonSmallBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Última comprobación: Hace 20 seg',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: vm.forceRecalculate,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.refresh,
                              color: AppColors.textPrimary,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Forzar Recálculo',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: Border.all(color: AppColors.buttonSmallBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shield,
                          color: AppColors.warningYellow,
                          size: 32,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Permanece estacionado en la berma autorizada. El sistema registrará tiempo detenido como ',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: 'PAUSA OPERATIVA.',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildParam(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildObstacleCard(
    String name,
    String detail,
    String badge,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
