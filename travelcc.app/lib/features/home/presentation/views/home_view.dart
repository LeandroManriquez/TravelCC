import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // 1. Ícono de Camión Grande (Logo visual)
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // 2. Texto pequeño superior (Eyebrow)
                Consumer<HomeViewModel>(
                  builder: (context, vm, child) => Center(
                    child: Text(
                      vm.eyebrow,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Título Gigante (Centrado)
                Consumer<HomeViewModel>(
                  builder: (context, vm, child) => Center(
                    child: Text(
                      vm.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineLarge.copyWith(
                        fontSize: 42,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 4. Subtítulo (Centrado)
                Consumer<HomeViewModel>(
                  builder: (context, vm, child) => Center(
                    child: Text(
                      vm.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // 5. Botón Naranja Principal con efecto "glow"
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      context.goNamed('login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.primary.withOpacity(0.5),
                    ),
                    child: Text(
                      'EXPLORAR PROYECTO',
                      style: AppTypography.button.copyWith(
                        fontSize: 15,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 6. Texto pequeño inferior
                const Center(
                  child: Text(
                    'Versión 1.0 · Hito 1',
                    style: TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
