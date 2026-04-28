import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/kline.dart';
import 'package:decimal/decimal.dart';

/// Smooth line chart of close prices, with a small floating label at the
/// peak (matching the screenshot — gray "$623.75" above the high point) and
/// a faint "BINANCE" watermark behind the line.
class PriceLineChart extends StatelessWidget {
  const PriceLineChart({
    required this.klines,
    required this.positive,
    super.key,
  });

  final List<Kline> klines;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    if (klines.length < 2) {
      return const SizedBox(height: 220);
    }

    final lineColor = positive ? AppColors.buy : AppColors.sell;

    final spots = <FlSpot>[];
    var peakIdx = 0;
    var peakValue = klines.first.close.toDouble();
    var minValue = peakValue;

    for (var i = 0; i < klines.length; i++) {
      final v = klines[i].close.toDouble();
      spots.add(FlSpot(i.toDouble(), v));
      if (v > peakValue) {
        peakValue = v;
        peakIdx = i;
      }
      if (v < minValue) minValue = v;
    }

    final range = peakValue - minValue;
    final padding = range == 0 ? peakValue * 0.01 : range * 0.1;
    final yMin = minValue - padding;
    final yMax = peakValue + padding;

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Center(
            child: Text(
              'BINANCE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (klines.length - 1).toDouble(),
                minY: yMin,
                maxY: yMax,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    preventCurveOverShooting: true,
                    color: lineColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          // Floating peak label.
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight - 32;
                final xFrac = peakIdx / (klines.length - 1);
                final yFrac = (peakValue - yMin) / (yMax - yMin);
                final left =
                    (xFrac * w).clamp(40.0, w - 80.0);
                // Inverse y because chart y grows up; the label sits above peak.
                final top = (32 + (1 - yFrac) * h - 22).clamp(8.0, h);
                return Stack(
                  children: [
                    Positioned(
                      left: left - 40,
                      top: top,
                      child: Text(
                        PriceFormatter.formatUsd(
                          Decimal.parse(peakValue.toStringAsFixed(8)),
                        ),
                        style: const TextStyle(
                          color: AppColors.lightTextTertiary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
