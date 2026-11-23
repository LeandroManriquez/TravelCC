import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../../../settings/presentation/views/settings_view.dart';
import '../viewmodels/driver_menu_viewmodel.dart';

class DriverMenuView extends StatelessWidget {
  const DriverMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverMenuViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.goNamed('map'),
          ),
          title: RichText(
            overflow: TextOverflow.ellipsis,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Menú ',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                TextSpan(
                  text: 'TravelCC',
                  style: TextStyle(
                    color: AppColors.actionOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Configuración',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsView(),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Consumer<DriverMenuViewModel>(
          builder: (context, vm, child) {
            return RefreshIndicator(
              color: AppColors.actionOrange,
              onRefresh: vm.loadDriverData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.panelDark,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        border: Border.all(color: AppColors.buttonSmallBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.actionOrange,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
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
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'ID: ${vm.driverShortId}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (vm.hasFleet
                                                ? AppColors.successGreen
                                                : AppColors.warningYellow)
                                            .withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        vm.fleetName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: vm.hasFleet
                                              ? AppColors.successGreen
                                              : AppColors.warningYellow,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Código rápido para compartir con Jefe de Flota
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.buttonSmallBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CÓDIGO PARA ENLAZAR FLOTA',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        vm.linkCode ?? 'Toca Generar para crear',
                                        style: TextStyle(
                                          color: vm.linkCode != null
                                              ? AppColors.actionOrange
                                              : AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing:
                                              vm.linkCode != null ? 2 : 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (vm.linkCode != null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      color: AppColors.textPrimary,
                                      size: 20,
                                    ),
                                    tooltip: 'Copiar código',
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: vm.linkCode!),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Código ${vm.linkCode} copiado al portapapeles',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ElevatedButton(
                                  onPressed: vm.isGeneratingCode
                                      ? null
                                      : () async {
                                          try {
                                            final code =
                                                await vm.generateLinkCode();
                                            if (code != null &&
                                                context.mounted) {
                                              await Clipboard.setData(
                                                ClipboardData(text: code),
                                              );
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Código $code generado y copiado',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.successGreen,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    e.toString().replaceFirst(
                                                        'Exception: ', ''),
                                                  ),
                                                  backgroundColor:
                                                      AppColors.criticalRed,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    vm.isGeneratingCode
                                        ? '...'
                                        : (vm.linkCode == null
                                            ? 'Generar'
                                            : 'Nuevo'),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    _buildMenuItem(
                      Icons.person_outline,
                      'Mi Perfil',
                      'Datos de chofer, código de enlace y flota',
                      () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileView(),
                          ),
                        );
                        vm.loadDriverData();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMenuItem(
                      Icons.settings,
                      'Configuración',
                      'Alertas, unidades y pantalla',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsView(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMenuItem(
                      Icons.route,
                      'Historial de Viajes',
                      'Registros anteriores y rutas completadas',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TripHistoryView(
                              driverName: vm.driverName,
                              assignedUnit: vm.assignedUnit,
                              truckDimensions: vm.truckDimensions,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    GestureDetector(
                      onTap: () => context.goNamed('vehicle'),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.panelDark,
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                          border: Border.all(
                            color: AppColors.buttonSmallBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_shipping,
                              color: AppColors.actionOrange,
                              size: 32,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'UNIDAD ASIGNADA',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    vm.assignedUnit,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'DIMENSIONES',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  vm.truckDimensions,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await vm.logout();
                          if (context.mounted) {
                            context.goNamed('login');
                          }
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.textPrimary,
                        ),
                        label: const Text(
                          'CERRAR SESIÓN',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.buttonSmallBorder,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'TravelCC Fleet OS',
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Volver al Mapa',
          onPressed: () => context.goNamed('map'),
          backgroundColor: AppColors.actionOrange,
          child: const Icon(Icons.map, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color iconColor = AppColors.actionOrange,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.panelDark,
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class TripHistoryView extends StatelessWidget {
  final String driverName;
  final String assignedUnit;
  final String truckDimensions;

  const TripHistoryView({
    super.key,
    required this.driverName,
    required this.assignedUnit,
    required this.truckDimensions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Historial de Viajes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.panelDark,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(color: AppColors.buttonSmallBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    color: AppColors.actionOrange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$assignedUnit · $truckDimensions',
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
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.panelDark,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    border: Border.all(color: AppColors.buttonSmallBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history_toggle_off,
                        size: 44,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sin viajes finalizados registrados',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Cuando completes rutas planificadas desde el mapa, tus recorridos aparecerán aquí.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.goNamed('map'),
                        icon: const Icon(Icons.map),
                        label: const Text('Ir al Mapa'),
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