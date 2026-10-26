import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              context.goNamed('home');
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Consumer<AuthViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Logo o Título
                      const Text(
                        'TRAVEL CC',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // 2. Campo de Usuario/Email
                      TextFormField(
                        controller: viewModel.emailController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Usuario o Correo',
                          labelStyle: const TextStyle(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.panel,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // 3. Campo de Contraseña
                      TextFormField(
                        controller: viewModel.passwordController,
                        obscureText: true,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: const TextStyle(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.panel,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // 4. Botón de Ingresar
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
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.sm,
                              ),
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
                                  'INGRESAR',
                                  style: AppTypography.button,
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
      ),
    );
  }
}
