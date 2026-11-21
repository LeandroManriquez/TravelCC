import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class FleetView extends StatelessWidget {
  const FleetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.goNamed('dashboard'),
        ),
        title: const Text(
          'Flota de Camiones',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.actionOrange),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de agregar camión en desarrollo'),
                  backgroundColor: AppColors.panelDark,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildTruckCard(
            context,
            'AB-12-34',
            'Juan Pérez',
            '4.2m / 25T / 12.5m',
            'En ruta',
            AppColors.successGreen,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTruckCard(
            context,
            'CD-56-78',
            'María González',
            '3.8m / 18T / 10.0m',
            'Disponible',
            AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTruckCard(
            context,
            'EF-90-12',
            'Carlos Ruiz',
            '4.5m / 30T / 14.0m',
            'Alerta',
            AppColors.criticalRed,
          ),
        ],
      ),
    );
  }

  Widget _buildTruckCard(
    BuildContext context,
    String patente,
    String conductor,
    String medidas,
    String estado,
    Color estadoColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                patente,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: estadoColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            conductor,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            medidas,
            style: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.goNamed('truckDetail'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.buttonSmallBorder),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                    ),
                  ),
                  child: const Text('VER DETALLE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
