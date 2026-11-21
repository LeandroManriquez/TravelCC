import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // 1. Placeholder del Mapa (Aquí irá tu lógica de mapa real en el Hito 2)
          Container(
            color: const Color(0xFF1A1D24),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: AppColors.textDisabled),
                  SizedBox(height: 16),
                  Text(
                    'Vista del Mapa (Placeholder)',
                    style: TextStyle(color: AppColors.textDisabled),
                  ),
                ],
              ),
            ),
          ),

          // 2. Barra Superior (Perfil y Camión)
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.goNamed('settings'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.panelDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.goNamed('vehicle'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.panelDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: AppColors.actionOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Panel Inferior de Búsqueda
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
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
                  const Icon(Icons.search, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Buscar destino, picada o taller...',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.star_border,
                      color: AppColors.warningYellow,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.location_on,
                      color: AppColors.secondary,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // 4. Botón Flotante de Reporte
          Positioned(
            bottom: 180,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => context.goNamed('report'),
              backgroundColor: AppColors.criticalRed,
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
