import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/active_route_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ActiveRouteView extends StatelessWidget {
  const ActiveRouteView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActiveRouteViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Stack(
          children: [
            // 1. Mapa de fondo (placeholder)
            Container(
              color: const Color(0xFF1A1D24),
              child: CustomPaint(
                size: Size.infinite,
                painter: MapRoutePainter(),
              ),
            ),

            // 2. Indicador superior de navegación
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Consumer<ActiveRouteViewModel>(
                builder: (context, vm, child) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.actionOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.turn_right,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vm.nextInstruction,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vm.nextRoad,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
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

            // 3. Alerta de precaución
            Positioned(
              top: 140,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(color: AppColors.warningYellow, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warningYellow,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Text(
                        'Precaución: Puente 4.2m a 2.5 km',
                        style: TextStyle(
                          color: AppColors.warningYellow,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Botón de camión (arriba derecha)
            Positioned(
              top: 50,
              right: 16,
              child: GestureDetector(
                onTap: () => context.goNamed('vehicle'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.actionOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

            // 5. Panel inferior de búsqueda
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.panelDark,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.actionOrange,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿A dónde vas?',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Buscar cliente, patio o parada',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warningYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: AppColors.warningYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 6. Panel de tiempo restante
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Consumer<ActiveRouteViewModel>(
                builder: (context, vm, child) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              '${vm.remainingMinutes} min · ${vm.remainingKm} km restantes',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Desliza detalles',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.actionOrange.withOpacity(0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.8,
      size.width * 0.5,
      size.height,
    );

    canvas.drawPath(path, paint);

    // Punto de inicio
    final startPaint = Paint()..color = AppColors.actionOrange;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.3),
      12,
      startPaint,
    );

    // Punto final
    canvas.drawCircle(Offset(size.width * 0.5, size.height), 12, startPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
