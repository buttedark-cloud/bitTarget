import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/glass_card.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/wallet/cubit/wallet_cubit.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionsSection extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionsSection({super.key, required this.transactions});

  static const int _preview = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.recentTransactions.toUpperCase(), style: AppTypography.titleLarge.copyWith(fontSize: 15)),
            PressEffect(
              onTap: () => _showAll(context),
              child: Text(l10n.viewAll, style: AppTypography.badgeGreen),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text(l10n.noTransactions, style: AppTypography.caption)),
          )
        else
          for (final tx in transactions.take(_preview))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TransactionTile(tx: tx),
            ),
      ],
    );
  }

  void _showAll(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121214),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => BlocBuilder<WalletCubit, WalletState>(
          builder: (_, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(l10n.allTransactions, style: AppTypography.titleLarge),
              ),
              Expanded(
                child: state.transactions.isEmpty
                    ? Center(child: Text(l10n.noTransactions, style: AppTypography.caption))
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: state.transactions.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TransactionTile(tx: state.transactions[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;

  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = tx.isIncome ? AppColors.neonGreen : AppColors.neonRed;
    final secondary = _secondary(l10n);

    return GlassCard(
      radius: 14,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(_icon(), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title(l10n), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodyLarge.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text('${_when(l10n)} • ${l10n.completed}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _primary(),
                style: AppTypography.bodyLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w800, color: color),
              ),
              if (secondary != null) ...[const SizedBox(height: 2), Text(secondary, style: AppTypography.caption)],
            ],
          ),
        ],
      ),
    );
  }

  IconData _icon() {
    switch (tx.type) {
      case TxType.buy:
        return Icons.trending_up_rounded;
      case TxType.sell:
        return Icons.trending_down_rounded;
      case TxType.depositUsd:
      case TxType.depositCrypto:
        return Icons.arrow_downward_rounded;
      case TxType.withdrawUsd:
        return Icons.arrow_upward_rounded;
      case TxType.transfer:
        return Icons.send_rounded;
      case TxType.reward:
        return Icons.emoji_events_outlined;
    }
  }

  String _title(AppLocalizations l10n) {
    switch (tx.type) {
      case TxType.buy:
        return '${l10n.buy} ${tx.symbol}';
      case TxType.sell:
        return '${l10n.sell} ${tx.symbol}';
      case TxType.depositUsd:
        return '${l10n.deposit} USD';
      case TxType.depositCrypto:
        return '${l10n.deposit} ${tx.symbol}';
      case TxType.withdrawUsd:
        return '${l10n.withdraw} USD';
      case TxType.transfer:
        return '${l10n.transfer} ${tx.symbol}';
      case TxType.reward:
        return l10n.txStaking;
    }
  }

  // Крупная сумма справа: в долларах или в монете, со знаком
  String _primary() {
    final sign = tx.isIncome ? '+' : '-';
    if (tx.symbol == 'USD') return '$sign${formatUsd(tx.amount)}';
    final qty = tx.amount.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
    return '$sign$qty ${tx.symbol}';
  }

  // Мелкая подпись под суммой
  String? _secondary(AppLocalizations l10n) {
    switch (tx.type) {
      case TxType.buy:
        return '-${formatUsd(tx.usd)}';
      case TxType.sell:
        return '+${formatUsd(tx.usd)}';
      case TxType.depositCrypto:
      case TxType.reward:
        return '≈ ${formatUsd(tx.usd)}';
      case TxType.transfer:
        return '${l10n.networkFee} ${formatUsd(tx.fee)}';
      case TxType.depositUsd:
      case TxType.withdrawUsd:
        return null;
    }
  }

  String _when(AppLocalizations l10n) {
    final now = DateTime.now();
    final time = DateFormat('HH:mm').format(tx.time);
    if (_sameDay(now, tx.time)) return '${l10n.today}, $time';
    if (_sameDay(now.subtract(const Duration(days: 1)), tx.time)) return '${l10n.yesterday}, $time';
    return '${DateFormat('dd.MM').format(tx.time)}, $time';
  }
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
