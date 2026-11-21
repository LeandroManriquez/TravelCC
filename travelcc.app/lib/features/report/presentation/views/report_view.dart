import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/report_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.goNamed('map'),
          ),
          title: const Text(
            'Reportar Incidencia',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<ReportViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isReporting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Enviando reporte al sistema...',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Text(
                    '¿Qué observas en la ruta?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildReportButton(
                    context,
                    'Accidente / Choque',
                    Icons.car_crash,
                    Colors.red,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildReportButton(
                    context,
                    'Obras en la vía',
                    Icons.construction,
                    Colors.orange,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildReportButton(
                    context,
                    'Puente o paso bajo',
                    Icons.height,
                    Colors.blue,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildReportButton(
                    context,
                    'Tráfico intenso',
                    Icons.traffic,
                    Colors.yellow,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<ReportViewModel>().reportIncident(title);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Gracias! Reporte de "$title" enviado.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) context.goNamed('map');
          });
        },
        icon: Icon(icon, color: Colors.white, size: 28),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
      ),
    );
  }
}
