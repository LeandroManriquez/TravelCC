import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../viewmodels/vehicle_viewmodel.dart';

class VehicleView extends StatelessWidget {
  const VehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VehicleViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.goNamed('map'),
          ),
          title: const Text(
            'Configurar Camión',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<VehicleViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IDENTIFICACIÓN Y DIMENSIONES',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: viewModel.plateController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Patente del Camión (ej: ABCD-12)',
                      labelStyle: TextStyle(color: AppColors.textMuted),
                      prefixIcon: Icon(
                        Icons.badge,
                        color: AppColors.actionOrange,
                      ),
                      filled: true,
                      fillColor: AppColors.panelDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.zero),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    'Altura (metros)',
                    viewModel.heightController,
                    Icons.height,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    'Peso Bruto (toneladas)',
                    viewModel.weightController,
                    Icons.scale,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    'Ancho (metros)',
                    viewModel.widthController,
                    Icons.straighten,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    'Largo (metros)',
                    viewModel.lengthController,
                    Icons.aspect_ratio,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'CONFIGURACIÓN DE EJES',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [2, 3, 4, 5, 6].map((ejes) {
                      final isSelected = viewModel.ejes == ejes;
                      return GestureDetector(
                        onTap: () => viewModel.setEjes(ejes),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.actionOrange
                                : AppColors.panelDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.actionOrange
                                  : AppColors.buttonSmallBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$ejes',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'PERMISOS Y CONDICIONES',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildToggle(
                    'Carga Peligrosa (IMO)',
                    viewModel.cargaPeligrosa,
                    viewModel.toggleCargaPeligrosa,
                    AppColors.warningYellow,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildToggle(
                    'Carga Sobredimensionada',
                    viewModel.cargaSobredimensionada,
                    viewModel.toggleCargaSobredimensionada,
                    AppColors.criticalRed,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildToggle(
                    'Carga Refrigerada',
                    viewModel.cargaRefrigerada,
                    viewModel.toggleCargaRefrigerada,
                    AppColors.secondary,
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              final err =
                                  await viewModel.saveVehicleDimensions();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    err ?? '¡Camión guardado en tu cuenta!',
                                  ),
                                  backgroundColor: err == null
                                      ? AppColors.successGreen
                                      : AppColors.criticalRed,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionOrange,
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'GUARDAR Y APLICAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.actionOrange),
        filled: true,
        fillColor: AppColors.panelDark,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.zero),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildToggle(
    String title,
    bool value,
    VoidCallback onChanged,
    Color activeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: (_) => onChanged(),
            activeThumbColor: activeColor,
            activeTrackColor: activeColor.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}