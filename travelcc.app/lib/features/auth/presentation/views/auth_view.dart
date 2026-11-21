import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Consumer<AuthViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'TRAVEL CC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.actionOrange,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const Text(
                      'TRANSPORTE Y LOGÍSTICA INTELIGENTE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Indicador de estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.actionOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.actionOrange.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_tethering,
                            color: AppColors.actionOrange,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'TERMINAL CAB CONECTADA',
                            style: TextStyle(
                              color: AppColors.actionOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Selector de Rol
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.panelDark,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => viewModel.selectRole('usuario'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: viewModel.selectedRole == 'usuario'
                                      ? AppColors.actionOrange
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.sm,
                                  ),
                                ),
                                child: const Text(
                                  'USUARIO',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => viewModel.selectRole('empresa'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: viewModel.selectedRole == 'empresa'
                                      ? AppColors.actionOrange
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.sm,
                                  ),
                                ),
                                child: const Text(
                                  'EMPRESA',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Campo ID
                    TextFormField(
                      controller: viewModel.idController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'IDENTIFICADOR DE FLOTA / RUT',
                        labelStyle: TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.panelDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.zero,
                          ), // Bordes rectos estilo industrial
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Campo Contraseña
                    TextFormField(
                      controller: viewModel.passwordController,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'CONTRASEÑA',
                        labelStyle: TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.panelDark,
                        suffixIcon: Icon(
                          Icons.visibility_off,
                          color: AppColors.textMuted,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.zero),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Recordar
                    Row(
                      children: [
                        Checkbox(
                          value: viewModel.rememberMe,
                          onChanged: (_) => viewModel.toggleRememberMe(),
                          activeColor: AppColors.actionOrange,
                        ),
                        const Text(
                          'Recordar en esta cabina',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Botón Ingresar
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                await viewModel.onLogin();
                                if (context.mounted) {
                                  context.goNamed('dashboard');
                                }
                              },
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
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'INICIAR SESIÓN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Huella / Face ID
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.fingerprint,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'Ingresar con Huella / Face ID',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.buttonSmallBorder,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Crear cuenta
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          '¿Nuevo transportista o flota? Crear una nueva cuenta',
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
