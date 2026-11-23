import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Pantalla 404: se muestra cuando la ruta pedida no existe.
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key, this.location});

  final String? location;

  @override
  Widget build(BuildContext context) {
    final path = location;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 72,
                  color: AppColors.actionOrange,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  '404',
                  style: TextStyle(
                    color: AppColors.actionOrange,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'RUTA NO ENCONTRADA',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'La pantalla que buscas no existe o fue movida.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                if (path != null && path.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    path,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    // Si hay sesión, el router lo manda a su pantalla de inicio; si no, al login.
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionOrange,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                    ),
                    child: const Text(
                      'VOLVER AL INICIO',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
