import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

abstract class AppTypography {
  // Базовый шрифт Inter
  static TextStyle get _baseStyle => GoogleFonts.inter();

  // 1. Огромный баланс / Крупные котировки ($84,920.50)
  static TextStyle displayLarge = _baseStyle.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
  );

  // 2. Средние цены и ценники монет ($66,092.843)
  static TextStyle displayMedium = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // 3. Заголовки секций (MASSIVE GROWTH TODAY, Asset Wallet)
  static TextStyle titleLarge = _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // 4. Названия валют и кнопок (Bitcoin BTC, Buy, Sell)
  static TextStyle bodyLarge = _baseStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  // 5. Стандартный текст (подписи к транзакциям)
  static TextStyle bodyMedium = _baseStyle.copyWith(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  // 6. Мелкие подписи, даты, 24h High/Low
  static TextStyle caption = _baseStyle.copyWith(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  // 7. Проценты роста (зеленые бейджи +14.82%)
  static TextStyle badgeGreen = _baseStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.neonGreen);

  // 8. Проценты падения (красные бейджи)
  static TextStyle badgeRed = _baseStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.neonRed);
}
