import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/map_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // 1. FONDO SIMULADO DEL MAPA (Placeholder para el Hito 1)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.panel, AppColors.panelSecondary],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 120,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Mapa en Vivo',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      '(Integración con Mapbox/Google Maps en Hito 2)',
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. BARRA SUPERIOR (Botón volver + Título + Configuración)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.8),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      // Botón Volver
                      IconButton(
                        onPressed: () => context.goNamed('dashboard'),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Mapa en Vivo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Botón Configuración
                      Consumer<MapViewModel>(
                        builder: (context, vm, child) => IconButton(
                          onPressed: vm.onSettings,
                          icon: const Icon(
                            Icons.settings,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. BARRA DE BÚSQUEDA
            Positioned(
              top: 80,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(color: AppColors.buttonSmallBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textMuted),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar dirección o ruta...',
                          hintStyle: TextStyle(color: AppColors.textDisabled),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. BOTONES FLOTANTES A LA DERECHA (GPS y más)
            Positioned(
              right: AppSpacing.md,
              bottom: 100,
              child: Column(
                children: [
                  // Botón Mi Ubicación
                  FloatingActionButton(
                    onPressed: () =>
                        context.read<MapViewModel>().onCenterLocation(),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Botón de capas del mapa
                  FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: AppColors.panel,
                    child: const Icon(
                      Icons.layers,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // 5. PANEL INFERIOR (Info de la ruta actual)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border.all(color: AppColors.buttonSmallBorder),
                ),
                child: Consumer<MapViewModel>(
                  builder: (context, vm, child) => Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.navigation,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ruta Actual',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vm.currentLocation,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'EN RUTA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
