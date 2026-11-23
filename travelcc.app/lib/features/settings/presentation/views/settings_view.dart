import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
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
                context.goNamed('map');
              }
            },
          ),
          title: const Text(
            'Configuración',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<SettingsViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UNIDADES Y MEDIDAS',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildUnitSelector('Distancia', vm.distanceUnit, [
                    'km',
                    'mi',
                  ], vm.setDistanceUnit),
                  const SizedBox(height: AppSpacing.md),
                  _buildUnitSelector('Peso', vm.weightUnit, [
                    't',
                    'lbs',
                  ], vm.setWeightUnit),
                  const SizedBox(height: AppSpacing.md),
                  _buildUnitSelector('Altura', vm.heightUnit, [
                    'm',
                    'ft',
                  ], vm.setHeightUnit),

                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'ALERTAS',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildToggle(
                    'Alertas por Voz',
                    vm.voiceAlerts,
                    vm.toggleVoiceAlerts,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildSlider(
                    'Volumen de Cabina',
                    vm.cabinVolume,
                    vm.setCabinVolume,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildToggle(
                    'Básculas de Pesaje',
                    vm.scaleAlerts,
                    vm.toggleScaleAlerts,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildToggle(
                    'Peajes y TAG',
                    vm.tollAlerts,
                    vm.toggleTollAlerts,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildToggle(
                    'Puentes y Restricciones',
                    vm.bridgeAlerts,
                    vm.toggleBridgeAlerts,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'PANTALLA Y MAPA',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildMapModeSelector(vm.mapMode, vm.setMapMode),

                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        vm.savePreferences();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Preferencias guardadas'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionOrange,
                      ),
                      child: const Text(
                        'GUARDAR PREFERENCIAS',
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

  Widget _buildUnitSelector(
    String label,
    String selected,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: options.map((opt) {
              final isSelected = selected == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.actionOrange
                          : AppColors.backgroundDark,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.actionOrange
                            : AppColors.buttonSmallBorder,
                      ),
                    ),
                    child: Text(
                      opt,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, VoidCallback onChanged) {
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
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: (_) => onChanged(),
            activeThumbColor: AppColors.actionOrange,
            activeTrackColor: AppColors.actionOrange.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  color: AppColors.actionOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 100,
            activeColor: AppColors.actionOrange,
            inactiveColor: AppColors.buttonSmallBorder,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMapModeSelector(String selected, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        border: Border.all(color: AppColors.buttonSmallBorder),
      ),
      child: Column(
        children: [
          _buildMapModeOption(
            'Siempre Oscuro',
            'dark',
            selected,
            onChanged,
            Icons.dark_mode,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildMapModeOption(
            'Automático',
            'auto',
            selected,
            onChanged,
            Icons.brightness_auto,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildMapModeOption(
            'Alto Contraste',
            'contrast',
            selected,
            onChanged,
            Icons.contrast,
          ),
        ],
      ),
    );
  }

  Widget _buildMapModeOption(
    String label,
    String value,
    String selected,
    Function(String) onChanged,
    IconData icon,
  ) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.actionOrange.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.actionOrange
                : AppColors.buttonSmallBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.actionOrange : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.actionOrange),
          ],
        ),
      ),
    );
  }
}