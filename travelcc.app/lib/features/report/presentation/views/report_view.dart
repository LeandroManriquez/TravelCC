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
                      'Obteniendo GPS y enviando reporte...',
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
                    title: 'Accidente / Choque',
                    typeCode: 'accident',
                    icon: Icons.car_crash,
                    color: Colors.red,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildReportButton(
                    context,
                    title: 'Obras en la vía',
                    typeCode: 'roadworks',
                    icon: Icons.construction,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildReportButton(
                    context,
                    title: 'Puente o paso bajo',
                    typeCode: 'low_bridge',
                    icon: Icons.height,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildReportButton(
                    context,
                    title: 'Tráfico intenso',
                    typeCode: 'heavy_traffic',
                    icon: Icons.traffic,
                    color: Colors.amber.shade700,
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
    BuildContext context, {
    required String title,
    required String typeCode,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: () async {
          final vm = context.read<ReportViewModel>();
          final ok = await vm.reportIncident(typeCode);
          if (!context.mounted) return;

          if (ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('¡Gracias! Reporte de "$title" guardado.'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.goNamed('map', queryParameters: {'reported': '1'});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(vm.errorMessage ?? 'Error al enviar reporte'),
                backgroundColor: AppColors.criticalRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
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