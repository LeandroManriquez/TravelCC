import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/map_models.dart';

class ActiveNavTopBanner extends StatelessWidget {
  final PlannedRouteInfo route;
  final double speedKmh;

  const ActiveNavTopBanner({
    super.key,
    required this.route,
    required this.speedKmh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: route.isCompatible
              ? AppColors.actionOrange
              : AppColors.criticalRed,
          width: 2,
        ),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 14)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.actionOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.navigation_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EN RUTA HACIA',
                  style: TextStyle(
                    color: AppColors.actionOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  route.destinationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  route.isCompatible
                      ? 'Vía apta · Camión ${route.truckPlate}'
                      : 'Precaución: ${route.blockingCount} alerta(s) vial(es)',
                  style: TextStyle(
                    color: route.isCompatible
                        ? AppColors.successGreen
                        : AppColors.criticalRed,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.buttonSmallBorder),
            ),
            child: Column(
              children: [
                Text(
                  speedKmh.round().toString(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'km/h',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportPopupCard extends StatelessWidget {
  final RoadReport report;
  final VoidCallback onClose;

  const ReportPopupCard({
    super.key,
    required this.report,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: report.color, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 14)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: report.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(report.icon, color: report.color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: report.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'REPORTE ACTIVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      report.timeAgoText,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  report.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (report.description != null &&
                    report.description!.isNotEmpty)
                  Text(
                    report.description!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.textMuted,
              size: 20,
            ),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class RoutePreviewCard extends StatelessWidget {
  final PlannedRouteInfo route;
  final VoidCallback onStartNavigation;
  final VoidCallback onClear;

  const RoutePreviewCard({
    super.key,
    required this.route,
    required this.onStartNavigation,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final extraDesc = route.firstRestrictionDesc != null
        ? ' (${route.firstRestrictionDesc})'
        : '';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: route.isCompatible
              ? AppColors.successGreen
              : AppColors.criticalRed,
          width: 1.5,
        ),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                route.isCompatible
                    ? Icons.check_circle
                    : Icons.warning_amber_rounded,
                color: route.isCompatible
                    ? AppColors.successGreen
                    : AppColors.criticalRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Destino: ${route.destinationName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${route.distanceKm.toStringAsFixed(1)} km · ${route.durationMinutes} min · Camión ${route.truckPlate}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            route.isCompatible
                ? 'Ruta compatible con altura y peso del camión'
                : 'ALERTA: ${route.blockingCount} restricción(es) vial(es)$extraDesc',
            style: TextStyle(
              color: route.isCompatible
                  ? AppColors.successGreen
                  : AppColors.criticalRed,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onStartNavigation,
              icon: const Icon(
                Icons.navigation_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'INICIAR RUTA',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveNavBottomBar extends StatelessWidget {
  final int remainingMinutes;
  final double remainingKm;
  final VoidCallback onStop;

  const ActiveNavBottomBar({
    super.key,
    required this.remainingMinutes,
    required this.remainingKm,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.buttonSmallBorder),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 14)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$remainingMinutes min · ${remainingKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Navegación activa · GPS enviando en vivo',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onStop,
            icon: const Icon(Icons.close, size: 18),
            label: const Text(
              'FINALIZAR',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}