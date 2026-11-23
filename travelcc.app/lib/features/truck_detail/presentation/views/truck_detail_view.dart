import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../fleet/presentation/viewmodels/fleet_viewmodel.dart';
import '../viewmodels/truck_detail_viewmodel.dart';

class TruckDetailView extends StatelessWidget {
  final Truck? truck;

  const TruckDetailView({super.key, this.truck});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TruckDetailViewModel(truck),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.goNamed('fleet'),
          ),
          title: Consumer<TruckDetailViewModel>(
            builder: (context, vm, _) => Text(
              vm.plate,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            Consumer<TruckDetailViewModel>(
              builder: (context, vm, _) => IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                tooltip: 'Actualizar telemetría',
                onPressed: vm.isRefreshing ? null : vm.refreshTruckData,
              ),
            ),
          ],
        ),
        body: Consumer<TruckDetailViewModel>(
          builder: (context, vm, child) {
            return RefreshIndicator(
              color: AppColors.actionOrange,
              onRefresh: vm.refreshTruckData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(
                      'Estado Actual',
                      vm.currentStatus,
                      vm.statusIcon,
                      vm.statusColor,
                      subtitle: vm.dimensions,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Fila: Velocidad + Botón Última Posición
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildStatBox(
                              title: 'Velocidad',
                              value: '${vm.displaySpeed.toStringAsFixed(0)} km/h',
                              icon: Icons.speed,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildLastPositionButton(context, vm),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    const Text(
                      'Conductor Asignado',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.panelDark,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        border: Border.all(color: AppColors.buttonSmallBorder),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.actionOrange,
                            child: Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vm.driverName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vm.driverPhone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Botón Llamar
                          _buildContactAction(
                            tooltip: 'Llamar al conductor',
                            backgroundColor:
                                AppColors.secondary.withValues(alpha: 0.16),
                            borderColor: AppColors.secondary,
                            onTap: () async {
                              final err = await vm.callDriver();
                              if (err != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(err),
                                    backgroundColor: AppColors.criticalRed,
                                  ),
                                );
                              }
                            },
                            child: const Icon(
                              Icons.call,
                              color: AppColors.secondary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Botón WhatsApp
                          _buildContactAction(
                            tooltip: 'Abrir chat en WhatsApp',
                            backgroundColor:
                                const Color(0xFF25D366).withValues(alpha: 0.18),
                            borderColor: const Color(0xFF25D366),
                            onTap: () async {
                              final err = await vm.openWhatsApp();
                              if (err != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(err),
                                    backgroundColor: AppColors.criticalRed,
                                  ),
                                );
                              }
                            },
                            child: const _WhatsAppBadgeIcon(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    Center(
                      child: Text(
                        'Última actualización: ${vm.lastUpdate}',
                        style: const TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLastPositionButton(
    BuildContext context,
    TruckDetailViewModel vm,
  ) {
    final activeColor =
        vm.hasPosition ? AppColors.actionOrange : AppColors.textDisabled;

    return Material(
      color: AppColors.panelDark,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        onTap: () {
          if (!vm.hasPosition) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Este camión aún no ha enviado coordenadas GPS por telemetría.',
                ),
                backgroundColor: AppColors.warningYellow,
              ),
            );
            return;
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TruckLastPositionMapView(
                plate: vm.plate,
                driverName: vm.driverName,
                lat: vm.lat!,
                lng: vm.lng!,
                speedKmh: vm.displaySpeed,
                lastUpdate: vm.lastUpdate,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(
              color: vm.hasPosition
                  ? AppColors.actionOrange.withValues(alpha: 0.6)
                  : AppColors.buttonSmallBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.location_on, color: activeColor, size: 24),
                  Icon(Icons.open_in_new, color: activeColor, size: 16),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                vm.hasPosition ? 'Ver en mapa' : 'Sin GPS',
                style: TextStyle(
                  color: vm.hasPosition
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Última posición',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactAction({
    required String tooltip,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withValues(alpha: 0.7)),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _WhatsAppBadgeIcon extends StatelessWidget {
  const _WhatsAppBadgeIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: const [
        Icon(
          Icons.chat_bubble,
          color: Color(0xFF25D366),
          size: 24,
        ),
        Icon(
          Icons.call,
          color: Colors.white,
          size: 12,
        ),
      ],
    );
  }
}

class TruckLastPositionMapView extends StatelessWidget {
  final String plate;
  final String driverName;
  final double lat;
  final double lng;
  final double speedKmh;
  final String lastUpdate;

  const TruckLastPositionMapView({
    super.key,
    required this.plate,
    required this.driverName,
    required this.lat,
    required this.lng,
    required this.speedKmh,
    required this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(lat, lng);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.panelDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Última posición · $plate',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.travelcc.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 120,
                      height: 76,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.panelDark,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.actionOrange,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              plate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.actionOrange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_shipping,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.panelDark,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(color: AppColors.buttonSmallBorder),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$plate · $driverName',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coordenadas: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Velocidad: ${speedKmh.toStringAsFixed(0)} km/h · $lastUpdate',
                    style: const TextStyle(
                      color: AppColors.actionOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}