import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class StopsExplorerView extends StatelessWidget {
  const StopsExplorerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.goNamed('map'),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rutas y Picadas',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'FAVORITOS EN RUTA 5',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.actionOrange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'TRAVELCC RUTA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          color: AppColors.textMuted,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Rutas Guardadas',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.actionOrange,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Picadas y Paradas',
                          style: TextStyle(
                            color: Colors.white,
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

            const SizedBox(height: AppSpacing.xl),
            const Text(
              'TUS RUTAS FRECUENTES',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.panelDark,
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.route,
                      color: AppColors.textMuted,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Sin rutas guardadas todavía',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Marca con una estrella tus trayectos frecuentes en el mapa para calcular tiempos, peajes y restricciones pesadas al instante.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'Explorar o Guardar Ruta',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.buttonSmallBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Picadas y Servicios en Carretera',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.actionOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'RADAR 30 KM',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.actionOrange,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Comida / Picadas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: Border.all(color: AppColors.buttonSmallBorder),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_parking,
                          color: AppColors.textMuted,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Estacionamiento 53ft',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            _buildStopCard(
              context,
              'PICADA DESTACADA',
              'Restaurante El Camionero Sureño',
              'KM 412 • RUTA 5 SUR',
              '4.8 km',
              [
                'Cazuelas y colaciones 24 hrs',
                'Parking 25 camiones vigilado',
                'Duchas calientes',
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStopCard(
              context,
              'ABIERTO 24/7',
              'Vulcanización Don Tito',
              'KM 398 • CRUCE SAN JAVIER',
              '18 km',
              [
                'Desmonte pesado y balanceo láser',
                'Aire alta presión 150 PSI',
                'Pana eléctrica móvil',
              ],
              isOpen: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStopCard(
              context,
              'TRUCK STOP OFICIAL',
              'Copec Truck Stop Los Conquistadores',
              'KM 375 • ACCESO BY-PASS',
              '31 km',
              [
                'Diésel flujo rápido (120 L/min)',
                'Pesaje por eje preventivo',
                'Cafetería Pronto & WiFi',
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.panelDark,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(color: AppColors.warningYellow),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warningYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.timer,
                      color: AppColors.warningYellow,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control de Descanso Legal (HOS)',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Te restan ',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: '1h 45m',
                                style: TextStyle(
                                  color: AppColors.warningYellow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' de conducción antes de tu pausa obligatoria de 30 min.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.panelDark,
          border: Border(top: BorderSide(color: AppColors.buttonSmallBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavIcon(Icons.local_shipping, 'RUTA', false),
            _buildBottomNavIcon(Icons.route, 'PARADAS', true),
            _buildBottomNavIcon(Icons.timer, 'HOS', false),
            _buildBottomNavIcon(Icons.tune, 'CONFIG', false),
          ],
        ),
      ),
    );
  }

  Widget _buildStopCard(
    BuildContext context,
    String badge,
    String name,
    String location,
    String distance,
    List<String> features, {
    bool isOpen = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badge == 'PICADA DESTACADA'
                      ? AppColors.warningYellow.withOpacity(0.2)
                      : AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: badge == 'PICADA DESTACADA'
                        ? AppColors.warningYellow
                        : AppColors.buttonSmallBorder,
                  ),
                ),
                child: Row(
                  children: [
                    if (isOpen)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (isOpen) const SizedBox(width: 4),
                    Text(
                      badge,
                      style: TextStyle(
                        color: badge == 'PICADA DESTACADA'
                            ? AppColors.warningYellow
                            : AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.navigation,
                    color: AppColors.textMuted,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'A $distance',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            location,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check,
                    color: AppColors.actionOrange,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    f,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.map,
                    color: AppColors.textPrimary,
                    size: 16,
                  ),
                  label: const Text(
                    'Ver en Mapa',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.buttonSmallBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: const Text(
                    'Fijar como Parada',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavIcon(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.actionOrange : AppColors.textMuted,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.actionOrange : AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
