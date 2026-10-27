import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class CoinIcon extends StatelessWidget {
  final String symbol;
  final double size;

  const CoinIcon({super.key, required this.symbol, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/icons/${symbol.toLowerCase()}.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          color: AppColors.cardBorder,
          alignment: Alignment.center,
          child: Text(symbol.isEmpty ? '?' : symbol[0], style: AppTypography.bodyLarge),
        ),
      ),
    );
  }
}
