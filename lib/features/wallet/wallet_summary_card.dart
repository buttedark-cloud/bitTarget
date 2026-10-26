import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class WalletSummaryCard extends StatelessWidget {
  final bool isEnglish;
  final double totalUsd;
  final double btcEquivalent;

  const WalletSummaryCard({super.key, required this.isEnglish, required this.totalUsd, required this.btcEquivalent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isEnglish ? 'Total balance (USD)' : 'Общий баланс (USD)', style: AppTypography.caption),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.neonGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('+24,8% ${isEnglish ? 'today' : 'за 24 часа'}', style: AppTypography.badgeGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('\$${totalUsd.toStringAsFixed(2)}', style: AppTypography.displayLarge.copyWith(fontSize: 32, color: Colors.white)),
          const SizedBox(height: 4),
          Text('≈ ${btcEquivalent.toStringAsFixed(6)} BTC', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          // Круглые кнопки действий (строго без квадратов!)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(Icons.arrow_downward, isEnglish ? 'Deposit' : 'Вклад'),
              _buildActionButton(Icons.arrow_upward, isEnglish ? 'Withdraw' : 'Отзывать'),
              _buildActionButton(Icons.swap_horiz, isEnglish ? 'Trade' : 'Торговля'),
              _buildActionButton(Icons.send_rounded, isEnglish ? 'Transfer' : 'Передача'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.neonGreen,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.neonGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
