import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/route_alert_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class RouteAlertView extends StatelessWidget {
  const RouteAlertView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RouteAlertViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Consumer<RouteAlertViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Banner de alerta
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.criticalRed.withOpacity(0.2),
                      border: Border.all(
                        color: AppColors.criticalRed,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.dangerous,
                                  color: AppColors.criticalRed,
                                  size: 28,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ALERTA VIAL CRÍTICA',
                                  style: TextStyle(
                                    color: AppColors.criticalRed,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'BLOQUEADO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'BLOQUEADO: RUTA NO APTA PARA TU CAMIÓN',
                          style: TextStyle(
                            color: AppColors.criticalRed,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.warningYellow,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${vm.route} (${vm.restriction})',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'RESTRICCIÓN FÍSICA',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildRestrictionCard(
                    'Límite de Altura',
                    'IMPACTO INMINENTE POR ALTURA',
                    'PASO MÁXIMO',
                    '${vm.maxHeight} m',
                    'TU CAMIÓN',
                    '${vm.truckHeight} m',
                    '+${(vm.truckHeight - vm.maxHeight) * 100} cm de colisión directa',
                    AppColors.criticalRed,
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'TONELAJE ESTRUCTURAL',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildRestrictionCard(
                    'Capacidad de Carga',
                    '+${(vm.truckWeight - vm.maxWeight).toInt()} TON EXCESO',
                    'CAPACIDAD MÁXIMA',
                    '${vm.maxWeight} Ton',
                    'PESO BRUTO',
                    '${vm.truckWeight} Ton',
                    'Infracción gravísima de tránsito',
                    AppColors.warningYellow,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.warningYellow.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.warningYellow,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.warningYellow,
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'PELIGRO DE ATRAPAMIENTO',
                              style: TextStyle(
                                color: AppColors.warningYellow,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Riesgo inminente de destrucción de tolva o daño severo a infraestructura ferroviaria. Tránsito no autorizado.',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'DESVÍO OBLIGATORIO',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      border: Border.all(color: AppColors.actionOrange),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.alt_route,
                          color: AppColors.actionOrange,
                          size: 32,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vm.deviation,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'DISTANCIA RESTANTE: ${vm.deviationDistance.toInt()} m',
                                style: const TextStyle(
                                  color: AppColors.warningYellow,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        vm.viewAlternativeRoute();
                        context.goNamed('routeCalculation');
                      },
                      icon: const Icon(Icons.alt_route, color: Colors.white),
                      label: const Text(
                        'VER RUTA ALTERNATIVA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionOrange,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: vm.stopInSafeZone,
                      icon: const Icon(
                        Icons.stop,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'DETENERSE EN ZONA SEGURA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.textPrimary),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero),
                        ),
                      ),
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

  Widget _buildRestrictionCard(
    String title,
    String badge,
    String label1,
    String value1,
    String label2,
    String value2,
    String warning,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: color,
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
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label1,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      value1,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label2,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      value2,
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  warning,
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
