import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

abstract class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(surface: AppColors.background, primary: AppColors.neonGreen, error: AppColors.neonRed),
      // Стили для карточек по умолчанию
      cardTheme: const CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
    );
  }
}
