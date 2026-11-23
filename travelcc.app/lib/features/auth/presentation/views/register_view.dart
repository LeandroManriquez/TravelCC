import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/register_viewmodel.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

InputDecoration _fieldDecoration(String label, {Widget? suffixIcon}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.panelDark,
    suffixIcon: suffixIcon,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.zero), // Bordes rectos estilo industrial
      borderSide: BorderSide.none,
    ),
  );
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  void _backToLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterViewModel(context.read<SessionController>()),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => _backToLogin(context),
          ),
          title: const Text(
            'CREAR CUENTA',
            style: TextStyle(
              color: AppColors.actionOrange,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Consumer<RegisterViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '¿Cómo vas a usar TRAVEL CC?',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Elección de tipo de cuenta
                    Row(
                      children: [
                        Expanded(
                          child: _RoleOption(
                            icon: Icons.local_shipping_outlined,
                            label: 'CONDUCTOR',
                            selected: !viewModel.isAdmin,
                            onTap: () =>
                                viewModel.selectRole(UserProfile.roleDriver),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _RoleOption(
                            icon: Icons.groups_outlined,
                            label: 'JEFE DE FLOTA',
                            selected: viewModel.isAdmin,
                            onTap: () =>
                                viewModel.selectRole(UserProfile.roleAdmin),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      viewModel.isAdmin
                          ? 'Ve en tiempo real dónde están los conductores de tu flota. '
                              'Requiere un plan de pago (en esta versión de demostración el pago es simulado).'
                          : 'Gratis. Calcula rutas aptas para las medidas de tu camión. '
                              'Más adelante puedes enlazarte a una flota con un código.',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    TextFormField(
                      controller: viewModel.fullNameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _fieldDecoration('NOMBRE COMPLETO'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (viewModel.isAdmin) ...[
                      TextFormField(
                        controller: viewModel.fleetNameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _fieldDecoration('NOMBRE DE LA FLOTA O EMPRESA'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    TextFormField(
                      controller: viewModel.emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _fieldDecoration('CORREO ELECTRÓNICO'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: viewModel.passwordController,
                      obscureText: viewModel.obscurePassword,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _fieldDecoration(
                        'CONTRASEÑA (MÍNIMO 8 CARACTERES)',
                        suffixIcon: IconButton(
                          onPressed: viewModel.togglePasswordVisibility,
                          icon: Icon(
                            viewModel.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: viewModel.confirmPasswordController,
                      obscureText: viewModel.obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => viewModel.onRegister(),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _fieldDecoration('CONFIRMAR CONTRASEÑA'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (viewModel.errorMessage != null) ...[
                      _MessageBox(
                        message: viewModel.errorMessage!,
                        color: AppColors.criticalRed,
                        icon: Icons.error_outline,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (viewModel.infoMessage != null) ...[
                      _MessageBox(
                        message: viewModel.infoMessage!,
                        color: AppColors.successGreen,
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const SizedBox(height: AppSpacing.md),

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            viewModel.isLoading ? null : viewModel.onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.actionOrange,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.zero),
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'CREAR CUENTA',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Center(
                      child: TextButton(
                        onPressed: () => _backToLogin(context),
                        child: const Text(
                          '¿Ya tienes cuenta? Inicia sesión',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.actionOrange : AppColors.panelDark,
          border: Border.all(
            color: selected ? AppColors.actionOrange : AppColors.buttonSmallBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
