import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/company_menu_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CompanyMenuView extends StatelessWidget {
  const CompanyMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyMenuViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.goNamed('dashboard'),
          ),
          title: const Text(
            'Menú Empresa',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.actionOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Consumer<CompanyMenuViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de empresa
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.panelDark,
                          AppColors.panelDark.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: Border.all(color: AppColors.buttonSmallBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PORTAL LOGÍSTICO',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vm.companyName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'RUT: ${vm.companyRut}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warningYellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.warningYellow,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: AppColors.warningYellow,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'CUENTA EMPRESA ACTIVA',
                                    style: TextStyle(
                                      color: AppColors.warningYellow,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              '🌐 ${vm.node}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.successGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Red en tránsito normal',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Sync ${vm.syncTime}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'GESTIÓN & CONTROL',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '5 Módulos',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildMenuItem(
                    Icons.business,
                    'Perfil Corporativo',
                    'Datos de facturación, sedes y apoderad...',
                    () => vm.goToProfile(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildMenuItem(
                    Icons.settings,
                    'Configuración',
                    'Parámetros globales de flota',
                    () => vm.goToSettings(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildMenuItem(
                    Icons.local_shipping,
                    'Flota de Camiones',
                    '${vm.totalTrucks} unidades activas',
                    () => context.goNamed('fleet'),
                    badge: '${vm.totalTrucks}',
                    highlight: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildMenuItem(
                    Icons.my_location,
                    'Monitoreo y Rutas',
                    'Telemetría en vivo y estado GPS',
                    () => vm.goToMonitoring(),
                    hasDot: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildMenuItem(
                    Icons.groups,
                    'Conductores Asignados',
                    'Turnos, licencias HOS y descansos',
                    () => vm.goToDrivers(),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.panelDark,
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DISPONIBILIDAD',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${vm.availability}%',
                                    style: const TextStyle(
                                      color: AppColors.successGreen,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.trending_up,
                                    color: AppColors.successGreen,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const Text(
                                'Sin retrasos críticos',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.panelDark,
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EN TRÁNSITO',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${vm.inTransit}',
                                      style: const TextStyle(
                                        color: AppColors.warningYellow,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' / ${vm.totalTrucks}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                '4 en base / mantención',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: vm.logout,
                      icon: const Icon(
                        Icons.logout,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'CERRAR SESIÓN CORPORATIVA',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.buttonSmallBorder,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const Center(
                    child: Text(
                      'TravelCC Enterprise v4.12.0 · build 9042',
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.goNamed('map'),
          backgroundColor: AppColors.actionOrange,
          child: const Icon(Icons.local_shipping, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    String? badge,
    bool highlight = false,
    bool hasDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: highlight
              ? AppColors.actionOrange.withOpacity(0.1)
              : AppColors.panelDark,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border(
            left: BorderSide(
              color: highlight ? AppColors.actionOrange : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: highlight
                    ? AppColors.actionOrange
                    : AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: highlight ? Colors.white : AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
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
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.actionOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (hasDot)
              const SizedBox(
                width: 8,
                child: Icon(
                  Icons.circle,
                  color: AppColors.warningYellow,
                  size: 8,
                ),
              ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
