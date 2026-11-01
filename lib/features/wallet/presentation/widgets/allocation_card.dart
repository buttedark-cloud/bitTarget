import 'dart:math' as math;

import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/glass_card.dart';
import 'package:bittarget/features/wallet/portfolio.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllocationCard extends StatelessWidget {
  final PortfolioSnapshot snapshot;

  const AllocationCard({super.key, required this.snapshot});

  static const List<Color> _palette = [Color(0xFF00FF66), Color(0xFF2ED8A3), Color(0xFF5CE1C8), Color(0xFF8AA09A), Color(0xFF4B5B57)];
  static const int _maxRows = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final all = snapshot.items;
    final shown = _group(all);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.assetAllocation, style: AppTypography.bodyLarge.copyWith(fontSize: 14)),
              Text('${all.length} ${l10n.assetsWord}', style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _donut(shown, l10n),
              const SizedBox(width: 16),
              Expanded(
                child: Column(children: [for (int i = 0; i < shown.length; i++) _legendRow(shown[i], _palette[i % _palette.length], l10n)]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<AllocationItem> _group(List<AllocationItem> items) {
    if (items.length <= _maxRows) return items;
    final head = items.take(_maxRows - 1).toList();
    final rest = items.skip(_maxRows - 1);
    final value = rest.fold<double>(0, (s, i) => s + i.value);
    final fraction = rest.fold<double>(0, (s, i) => s + i.fraction);
    return [...head, AllocationItem('OTHER', value, fraction)];
  }

  String _label(AllocationItem item, AppLocalizations l10n) => item.symbol == 'OTHER' ? l10n.other : item.symbol;

  String _pct(double f) => (f > 0 && f < 0.01) ? '<1' : (f * 100).round().toString();

  String _money(double v) => v >= 100 ? '\$${NumberFormat('#,##0').format(v)}' : formatUsd(v);

  Widget _donut(List<AllocationItem> shown, AppLocalizations l10n) {
    final top = shown.isEmpty ? null : shown.first;
    final fractions = [for (final i in shown) i.fraction];
    final colors = [for (int k = 0; k < shown.length; k++) _palette[k % _palette.length]];

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, progress, _) => CustomPaint(size: const Size(120, 120), painter: _DonutPainter(fractions, colors, progress)),
          ),
          if (top != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_label(top, l10n), style: AppTypography.caption),
                Text(
                  '${_pct(top.fraction)}%',
                  style: AppTypography.bodyLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.neonGreen),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _legendRow(AllocationItem item, Color color, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${_label(item, l10n)} (${_pct(item.fraction)}%)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(fontSize: 11, color: Colors.white70),
                ),
              ),
              Text(_money(item.value), style: AppTypography.bodyLarge.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.fraction.clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> fractions;
  final List<Color> colors;
  final double progress;

  _DonutPainter(this.fractions, this.colors, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.shortestSide / 2 - stroke / 2);

    // Серая «дорожка» под цветными дугами
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.white.withValues(alpha: 0.05),
    );

    final gap = fractions.length > 1 ? 0.05 : 0.0; // маленький просвет между дугами
    var start = -math.pi / 2;

    for (int i = 0; i < fractions.length; i++) {
      final full = fractions[i] * 2 * math.pi;
      final sweep = math.max(0.0, full - gap) * progress;
      if (sweep > 0) {
        canvas.drawArc(
          rect,
          start + gap / 2,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..color = colors[i],
        );
      }
      start += full;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}
