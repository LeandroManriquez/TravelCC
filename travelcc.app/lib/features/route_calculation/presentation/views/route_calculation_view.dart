import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/route_calculation_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class RouteCalculationView extends StatelessWidget {
  const RouteCalculationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RouteCalculationViewModel()..startCalculation(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.goNamed('routeAlert'),
          ),
          title: const Text(
            'Telemetría Cabina',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.gps_fixed,
                    color: AppColors.warningYellow,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'GPS LOCK 100%',
                    style: TextStyle(
                      color: AppColors.warningYellow,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Consumer<RouteCalculationViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  // Círculo de progreso
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(200, 200),
                          painter: ProgressCirclePainter(vm.progress),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_shipping,
                              color: AppColors.actionOrange,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${vm.progress.toInt()}%',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Calculando ruta apta para tu camión...',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Verificando gálibo vertical, restricciones de peso por puente y autorización de carga en ruta activa',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  _buildCheckItem(
                    'Gálibo Mínimo Viaductos',
                    '4.50 M SEGURO',
                    AppColors.successGreen,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildCheckItem(
                    'Límites Ejes & Puentes',
                    'VÍA CONCESIÓN',
                    AppColors.warningYellow,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      border: Border.all(color: AppColors.buttonSmallBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PARÁMETROS FICHA TÉCNICA',
                              style: TextStyle(
                                color: AppColors.warningYellow,
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'ID #VH-8820',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTechParam(
                                'UNIDAD',
                                vm.vehicleId,
                                vm.vehicleModel,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _buildTechParam(
                                'PESO BRUTO',
                                vm.weight,
                                'Carga Máx',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _buildTechParam(
                                'ALTURA',
                                vm.height,
                                'Con Deflector',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        vm.cancelCalculation();
                        context.goNamed('vehicle');
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'CANCELAR Y MODIFICAR FILTROS',
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

  Widget _buildCheckItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechParam(String label, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textDisabled, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// Pintor personalizado para el círculo de progreso
class ProgressCirclePainter extends CustomPainter {
  final double progress;

  ProgressCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Fondo del círculo
    final bgPaint = Paint()
      ..color = AppColors.panelDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, bgPaint);

    // Progreso
    final progressPaint = Paint()
      ..color = AppColors.actionOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * (progress / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
