import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.goNamed('driverMenu');
              }
            },
          ),
          title: const Text(
            'Mi Perfil',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.actionOrange),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: Border.all(
                        color: AppColors.actionOrange,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.actionOrange,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.textMuted,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CONDUCTOR TRAVELCC',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vm.driverName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ID Corto: ${vm.shortId}',
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

                  const SizedBox(height: AppSpacing.md),
                  // Código de Enlace Compartible
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.panelDark,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: Border.all(color: AppColors.buttonSmallBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ENLACE CON JEFE DE FLOTA',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          vm.fleetName != null
                              ? 'Flota actual: ${vm.fleetName}'
                              : 'Actualmente sin flota (Modo Libre)',
                          style: TextStyle(
                            color: vm.fleetName != null
                                ? AppColors.successGreen
                                : AppColors.warningYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (vm.linkCode != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.actionOrange),
                            ),
                            child: Center(
                              child: Text(
                                vm.linkCode!,
                                style: const TextStyle(
                                  color: AppColors.actionOrange,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: vm.linkCode!),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Código copiado'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy, size: 18),
                                  label: const Text('Copiar Código'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final shareMsg =
                                        'Hola, soy ${vm.driverName} en TravelCC. Mi código para enlazarme a tu flota es: ${vm.linkCode}';
                                    Clipboard.setData(
                                      ClipboardData(text: shareMsg),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Mensaje listo para pegar en WhatsApp / Chat',
                                        ),
                                        backgroundColor: AppColors.successGreen,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.share, size: 18),
                                  label: const Text('Compartir'),
                                ),
                              ),
                            ],
                          ),
                        ] else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: vm.isGeneratingCode
                                  ? null
                                  : () async {
                                      final err = await vm.generateLinkCode();
                                      if (err != null && context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(err),
                                            backgroundColor:
                                                AppColors.criticalRed,
                                          ),
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.qr_code_2),
                              label: const Text(
                                'Generar Código de Enlace (8 dígitos)',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  _buildDataField(
                    'CORREO REGISTRADO',
                    vm.email.isEmpty ? 'Sin correo' : vm.email,
                    Icons.copy,
                    onCopy: vm.email.isEmpty
                        ? null
                        : () {
                            Clipboard.setData(ClipboardData(text: vm.email));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Correo copiado')),
                            );
                          },
                  ),

                  const SizedBox(height: AppSpacing.md),
                  _buildPhoneField(context, vm),

                  const SizedBox(height: AppSpacing.md),
                  GestureDetector(
                    onTap: () => context.goNamed('vehicle'),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.panelDark,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_shipping,
                              color: AppColors.actionOrange,
                              size: 28,
                            ),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  vm.unitDimensions,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditDialog(context, vm),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Editar Nombre',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Salir de la flota: abajo del todo, justo arriba de Cerrar Sesión
                  if (vm.fleetName != null || vm.isInFleet) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: vm.isLeavingFleet
                            ? null
                            : () => _confirmAndLeaveFleet(context, vm),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.criticalRed),
                        ),
                        icon: vm.isLeavingFleet
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.criticalRed,
                                ),
                              )
                            : const Icon(
                                Icons.exit_to_app,
                                color: AppColors.criticalRed,
                              ),
                        label: const Text(
                          'Salir de la flota actual',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.criticalRed,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
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
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDataField(
    String label,
    String value,
    IconData? icon, {
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (icon != null && onCopy != null)
            IconButton(
              icon: Icon(icon, color: AppColors.textMuted, size: 20),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context, ProfileViewModel vm) {
    final hasPhone = vm.phone.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TELÉFONO DE CONTACTO',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPhone ? vm.phone : 'Sin teléfono registrado',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasPhone
                        ? AppColors.textPrimary
                        : AppColors.warningYellow,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _showEditPhoneDialog(context, vm),
            icon: Icon(
              hasPhone ? Icons.edit : Icons.add_call,
              size: 18,
              color: AppColors.actionOrange,
            ),
            label: Text(
              hasPhone ? 'Editar' : 'Registrar',
              style: const TextStyle(
                color: AppColors.actionOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPhoneDialog(
    BuildContext context,
    ProfileViewModel vm,
  ) async {
    final controller = TextEditingController(text: vm.phone);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: Text(
          vm.phone.trim().isEmpty
              ? 'Registrar Teléfono'
              : 'Editar Teléfono',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Número de teléfono',
            hintText: '+56 9 1234 5678',
            labelStyle: TextStyle(color: AppColors.textMuted),
            hintStyle: TextStyle(color: AppColors.textMuted),
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

    if (saved == true && context.mounted) {
      final err = await vm.updatePhone(controller.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Teléfono guardado'),
            backgroundColor:
                err == null ? AppColors.successGreen : AppColors.criticalRed,
          ),
        );
      }
    }
  }

  Future<void> _confirmAndLeaveFleet(
    BuildContext context,
    ProfileViewModel vm,
  ) async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text(
          'Salir de la flota actual',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Dejarás de pertenecer a ${vm.fleetName ?? 'tu flota actual'} y pasarás a Modo Libre.',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (firstConfirm != true || !context.mounted) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text(
          'Confirmación final',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Está seguro que quiere realizar esta acción?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalRed,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, salir'),
          ),
        ],
      ),
    );

    if (secondConfirm != true || !context.mounted) return;

    final err = await vm.leaveFleet();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Saliste de la flota'),
          backgroundColor:
              err == null ? AppColors.successGreen : AppColors.criticalRed,
        ),
      );
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    ProfileViewModel vm,
  ) async {
    final controller = TextEditingController(text: vm.driverName);
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
      final err = await vm.updateName(controller.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Perfil actualizado'),
            backgroundColor:
                err == null ? AppColors.successGreen : AppColors.criticalRed,
          ),
        );
      }
    }
  }
}