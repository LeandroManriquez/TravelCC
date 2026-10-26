import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Bordes, radios y sombras reutilizables.
abstract final class AppDecoration {
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;

  static BoxDecoration get panelDecoration => BoxDecoration(
    color: AppColors.panel,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: AppColors.buttonSmallBorder, width: 0.5),
  );

  static List<BoxShadow> get glowOrange => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.2),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];
}
