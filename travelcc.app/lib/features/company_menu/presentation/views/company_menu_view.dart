import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../settings/presentation/views/settings_view.dart';
import '../viewmodels/company_menu_viewmodel.dart';

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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<CompanyMenuViewModel>(
              builder: (context, vm, _) => IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: AppColors.textPrimary,
                ),
                tooltip: 'Sincronizar',
                onPressed: vm.isLoading ? null : vm.loadCompanyData,
              ),
            ),
          ],
        ),
        body: Consumer<CompanyMenuViewModel>(
          builder: (context, vm, child) {
            return RefreshIndicator(
              color: AppColors.actionOrange,
              onRefresh: vm.loadCompanyData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.panelDark,
                            AppColors.panelDark.withValues(alpha: 0.6),
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Encargado: ${vm.bossName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (vm.isPlanActive
                                            ? AppColors.warningYellow
                                            : AppColors.criticalRed)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: vm.isPlanActive
                                          ? AppColors.warningYellow
                                          : AppColors.criticalRed,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        vm.isPlanActive
                                            ? Icons.verified
                                            : Icons.warning_amber_rounded,
                                        color: vm.isPlanActive
                                            ? AppColors.warningYellow
                                            : AppColors.criticalRed,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          vm.isPlanActive
                                              ? 'CUENTA EMPRESA ACTIVA'
                                              : 'PLAN INACTIVO',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: vm.isPlanActive
                                                ? AppColors.warningYellow
                                                : AppColors.criticalRed,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (vm.bossEmail.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    vm.bossEmail,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.criticalRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                          border: Border.all(color: AppColors.criticalRed),
                        ),
                        child: Text(
                          vm.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: vm.isLoading
                                    ? AppColors.warningYellow
                                    : AppColors.successGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              vm.isLoading
                                  ? 'Sincronizando flota...'
                                  : 'Red operativa conectada',
                              style: const TextStyle(
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GESTIÓN & CONTROL',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          '5 Módulos',
                          style: TextStyle(
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
                      'Datos de empresa, plan y encargado',
                      () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: vm,
                              child: const CompanyProfileView(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMenuItem(
                      Icons.settings,
                      'Configuración',
                      'Parámetros globales de flota y alertas',
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
                      Icons.local_shipping,
                      'Flota de Camiones',
                      vm.totalTrucks == 1
                          ? '1 unidad asignada a tu flota'
                          : '${vm.totalTrucks} unidades asignadas a tu flota',
                      () => context.goNamed('fleet'),
                      badge: '${vm.totalTrucks}',
                      highlight: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMenuItem(
                      Icons.my_location,
                      'Monitoreo y Rutas',
                      'Telemetría GPS en vivo de tus camiones',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FleetMonitoringView(),
                          ),
                        );
                      },
                      hasDot: vm.inTransit > 0,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMenuItem(
                      Icons.groups,
                      'Conductores Asignados',
                      'Enlazar por código o desvincular choferes',
                      () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: vm,
                              child: const AssignedDriversView(),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.panelDark,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.md,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DISPONIBILIDAD GPS',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${vm.availability.toStringAsFixed(0)}%',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.successGreen,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.trending_up,
                                      color: AppColors.successGreen,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                Text(
                                  vm.totalTrucks == 0
                                      ? 'Sin unidades aún'
                                      : 'Reportando últimos 5 min',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
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
                              borderRadius: BorderRadius.circular(
                                AppSpacing.md,
                              ),
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
                                Text(
                                  '${vm.stationaryCount} en base / sin señal',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
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
                        'TravelCC Enterprise · Gestión de Flota',
                        style: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Mapa de Flota en Vivo',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const FleetMonitoringView(),
              ),
            );
          },
          backgroundColor: AppColors.actionOrange,
          child: const Icon(Icons.my_location, color: Colors.white),
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
              ? AppColors.actionOrange.withValues(alpha: 0.1)
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
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
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
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            if (hasDot) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.circle,
                color: AppColors.successGreen,
                size: 8,
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class CompanyProfileView extends StatelessWidget {
  const CompanyProfileView({super.key});

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
          'Perfil Corporativo',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<CompanyMenuViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.panelDark,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    border: Border.all(color: AppColors.actionOrange, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EMPRESA / FLOTA REGISTRADA',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        vm.companyName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'ID Flota: ${vm.fleetId.isEmpty ? "No asignado" : vm.fleetId}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (vm.fleetId.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              tooltip: 'Copiar ID de flota',
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: vm.fleetId),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ID de flota copiado'),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _infoTile('ENCARGADO DE FLOTA', vm.bossName, Icons.person),
                const SizedBox(height: AppSpacing.sm),
                _infoTile(
                  'CORREO CORPORATIVO',
                  vm.bossEmail.isEmpty ? 'Sin correo' : vm.bossEmail,
                  Icons.email_outlined,
                ),
                const SizedBox(height: AppSpacing.sm),
                _infoTile(
                  'UNIDADES EN FLOTA',
                  '${vm.totalTrucks} camión(es) (${vm.inTransit} activos)',
                  Icons.local_shipping,
                ),
                const SizedBox(height: AppSpacing.sm),
                _infoTile(
                  'ESTADO DE SUSCRIPCIÓN',
                  vm.isPlanActive ? 'ACTIVO' : 'INACTIVO',
                  Icons.verified_outlined,
                  valueColor: vm.isPlanActive
                      ? AppColors.successGreen
                      : AppColors.warningYellow,
                ),
                if (!vm.isPlanActive) ...[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final err = await vm.activateDemoPlan();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              err ?? 'Plan corporativo activado (Demo)',
                            ),
                            backgroundColor: err == null
                                ? AppColors.successGreen
                                : AppColors.criticalRed,
                          ),
                        );
                      },
                      icon: const Icon(Icons.bolt),
                      label: const Text('Activar Plan Flota (Demo)'),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditNameDialog(context, vm),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Editar Nombre del Encargado',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(
    String label,
    String value,
    IconData icon, {
    Color valueColor = AppColors.textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.actionOrange, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    CompanyMenuViewModel vm,
  ) async {
    final controller = TextEditingController(text: vm.bossName);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text(
          'Editar Nombre',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
            labelStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (saved == true && controller.text.trim().length >= 2) {
      final err = await vm.updateBossName(controller.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Nombre actualizado correctamente'),
            backgroundColor:
                err == null ? AppColors.successGreen : AppColors.criticalRed,
          ),
        );
      }
    }
  }
}

class AssignedDriversView extends StatelessWidget {
  const AssignedDriversView({super.key});

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
          'Conductores Asignados',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<CompanyMenuViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: const Icon(Icons.person_add, color: AppColors.actionOrange),
              tooltip: 'Enlazar conductor con código',
              onPressed: () => _showLinkDriverDialog(context, vm),
            ),
          ),
        ],
      ),
      body: Consumer<CompanyMenuViewModel>(
        builder: (context, vm, _) {
          final assigned = vm.trucks.where((t) => t.driverId != null).toList();
          return RefreshIndicator(
            color: AppColors.actionOrange,
            onRefresh: vm.loadCompanyData,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLinkDriverDialog(context, vm),
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text(
                      'ENLAZAR CONDUCTOR CON CÓDIGO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (vm.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        color: AppColors.actionOrange,
                      ),
                    ),
                  )
                else if (assigned.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: Border.all(color: AppColors.buttonSmallBorder),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Aún no tienes conductores enlazados',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Pide a tu conductor su código de 8 caracteres desde su perfil y enlázalo aquí.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...assigned.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.panelDark,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        border: Border.all(color: AppColors.buttonSmallBorder),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.actionOrange,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.driverName ?? 'Conductor',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Camión: ${item.plate} · ${item.isRecentlyActive ? "En ruta" : "Sin movimiento reciente"}',
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
                              Icons.link_off,
                              color: AppColors.criticalRed,
                            ),
                            tooltip: 'Desvincular de la flota',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.panelDark,
                                  title: const Text(
                                    'Desvincular conductor',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  content: Text(
                                    '¿Seguro que deseas desvincular a ${item.driverName ?? "este conductor"} de tu flota?',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.criticalRed,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: const Text('Desvincular'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && item.driverId != null) {
                                try {
                                  await vm.unlinkDriver(item.driverId!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Conductor desvinculado de la flota',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: AppColors.criticalRed,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showLinkDriverDialog(
    BuildContext context,
    CompanyMenuViewModel vm,
  ) async {
    final codeController = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text(
          'Enlazar Conductor',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
            color: AppColors.textPrimary,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            hintText: 'Ej: ABCD-1234',
            hintStyle: TextStyle(color: AppColors.textMuted),
            labelText: 'Código de enlace del chofer',
            labelStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Enlazar'),
          ),
        ],
      ),
    );

    if (submitted == true && codeController.text.trim().isNotEmpty) {
      try {
        final msg = await vm.linkDriverByCode(codeController.text);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg ?? 'Conductor enlazado'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: AppColors.criticalRed,
            ),
          );
        }
      }
    }
  }
}

class FleetMonitoringView extends StatefulWidget {
  const FleetMonitoringView({super.key});

  @override
  State<FleetMonitoringView> createState() => _FleetMonitoringViewState();
}

class _FleetMonitoringViewState extends State<FleetMonitoringView> {
  Timer? _pollingTimer;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = CompanyMenuViewModel();
        _pollingTimer = Timer.periodic(
          const Duration(seconds: 10),
          (_) => vm.loadCompanyData(),
        );
        return vm;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Monitoreo y Rutas en Vivo',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<CompanyMenuViewModel>(
              builder: (context, vm, _) => IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                onPressed: vm.isLoading ? null : vm.loadCompanyData,
              ),
            ),
          ],
        ),
        body: Consumer<CompanyMenuViewModel>(
          builder: (context, vm, _) {
            final positioned = vm.trucks.where((t) => t.hasPosition).toList();
            final center = positioned.isNotEmpty
                ? LatLng(positioned.first.lat!, positioned.first.lng!)
                : const LatLng(-33.4489, -70.6693);

            return Column(
              children: [
                Expanded(
                  flex: 3,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 12.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.travelcc.app',
                      ),
                      MarkerLayer(
                        markers: positioned.map((truck) {
                          return Marker(
                            point: LatLng(truck.lat!, truck.lng!),
                            width: 110,
                            height: 68,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.panelDark,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.actionOrange,
                                    ),
                                  ),
                                  child: Text(
                                    truck.plate,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: truck.isRecentlyActive
                                        ? AppColors.successGreen
                                        : AppColors.actionOrange,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: const BoxDecoration(
                      color: AppColors.panelDark,
                      border: Border(
                        top: BorderSide(color: AppColors.buttonSmallBorder),
                      ),
                    ),
                    child: vm.trucks.isEmpty
                        ? Center(
                            child: Text(
                              vm.errorMessage ??
                                  'No hay camiones registrados en tu flota.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: vm.trucks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final t = vm.trucks[idx];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundDark,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_shipping,
                                      color: t.isRecentlyActive
                                          ? AppColors.successGreen
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${t.plate} · ${t.driverName ?? "Sin chofer"}',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            t.hasPosition
                                                ? 'GPS: ${t.lat!.toStringAsFixed(4)}, ${t.lng!.toStringAsFixed(4)} · ${(t.speedKmh ?? 0).toStringAsFixed(0)} km/h'
                                                : 'Sin coordenadas GPS reportadas',
                                            overflow: TextOverflow.ellipsis,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}