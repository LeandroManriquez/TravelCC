import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
          // ==========================================
          // 1. EL MAPA REAL (CORREGIDO PARA QUE SE VEA EN WEB/TABLET)
          // ==========================================
          Positioned.fill(
            // 👈 Esto obliga al mapa a ocupar todo el fondo
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(-33.4489, -70.6693),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.travelcc.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(-33.4489, -70.6693),
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.actionOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. UI SUPERPUESTA: Barra Superior
          // ==========================================
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.goNamed('driverMenu'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.panelDark,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black45, blurRadius: 4),
                      ],
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
                      boxShadow: [
                        BoxShadow(color: Colors.black45, blurRadius: 4),
                      ],
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

          // ==========================================
          // 3. UI SUPERPUESTA: Buscador Inferior (CORREGIDO)
          // ==========================================
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.panelDark,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                  // 👇 CAMBIADO DE 'Text' A 'TextField' PARA PODER ESCRIBIR
                  Expanded(
                    child: TextField(
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Buscar destino, picada o taller...',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  // 👇 ESTRELLA CONECTADA A LA PANTALLA DE PARADAS
                  IconButton(
                    icon: const Icon(
                      Icons.star_border,
                      color: AppColors.warningYellow,
                    ),
                    onPressed: () => context.goNamed('stops'),
                  ),
                  // 👇 PIN CON UN MENSAJE DE "EN DESARROLLO"
                  IconButton(
                    icon: const Icon(
                      Icons.location_on,
                      color: AppColors.secondary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Buscando paradas cercanas... (Próximamente)',
                          ),
                          backgroundColor: AppColors.panelDark,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 4. UI SUPERPUESTA: Botón Flotante de Reporte
          // ==========================================
          Positioned(
            bottom: 180,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => context.goNamed('report'),
              backgroundColor: AppColors.criticalRed,
              elevation: 4,
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
