import 'dart:math' as math;

import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/utils/date_formatting.dart';
import 'package:cal_tab/widgets/shared/app_card.dart';
import 'package:flutter/material.dart';

String _formatAxisDate(DateTime date, {required bool includeYear}) {
  final short = formatShortDate(date);
  return includeYear ? '$short ${date.year}' : short;
}

class WeightChartCard extends StatelessWidget {
  const WeightChartCard({
    super.key,
    required this.baselineWeightKg,
    required this.entries,
  });

  final double baselineWeightKg;
  final List<BodyProgressEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final sortedAsc = entries.reversed.toList(growable: false);
    final labelStyle =
        textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant) ??
        TextStyle(color: colors.onSurfaceVariant, fontSize: 11);

    final includeYearOnBounds = sortedAsc.length >= 2 &&
        sortedAsc.first.date.year != sortedAsc.last.date.year;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight over time',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Weight in kg',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (sortedAsc.length < 2)
            Container(
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Add at least two entries to see your trend line.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _WeightChartPainter(
                  entries: sortedAsc,
                  baselineWeight: baselineWeightKg,
                  colorScheme: colors,
                  labelStyle: labelStyle,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(44, 12, 12, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            _formatAxisDate(
                              sortedAsc.first.date,
                              includeYear: includeYearOnBounds,
                            ),
                            style: labelStyle,
                          ),
                          const Spacer(),
                          Text(
                            _formatAxisDate(
                              sortedAsc.last.date,
                              includeYear: true,
                            ),
                            style: labelStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({
    required this.entries,
    required this.baselineWeight,
    required this.colorScheme,
    required this.labelStyle,
  });

  final List<BodyProgressEntry> entries;
  final double baselineWeight;
  final ColorScheme colorScheme;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 44.0;
    const rightPad = 12.0;
    const topPad = 12.0;
    const bottomPad = 28.0;
    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final weights = <double>[baselineWeight, ...entries.map((e) => e.weightKg)];
    final minWeight = weights.reduce(math.min);
    final maxWeight = weights.reduce(math.max);
    final spread = math.max(1.0, maxWeight - minWeight);
    final low = minWeight - spread * 0.15;
    final high = maxWeight + spread * 0.15;
    final range = math.max(0.5, high - low);

    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = topPad + chartHeight * i / 3;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );

      final value = high - (range * i / 3);
      final tp = TextPainter(
        text: TextSpan(
          text: '${value.toStringAsFixed(1)} kg',
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: leftPad - 4);
      tp.paint(canvas, Offset(leftPad - 6 - tp.width, y - tp.height / 2));
    }

    final pointOffsets = <Offset>[];
    final firstDateMs = entries.first.date.millisecondsSinceEpoch.toDouble();
    final lastDateMs = entries.last.date.millisecondsSinceEpoch.toDouble();
    final totalDateSpanMs = math.max(1.0, lastDateMs - firstDateMs);

    for (var i = 0; i < entries.length; i++) {
      final dateMs = entries[i].date.millisecondsSinceEpoch.toDouble();
      final dateRatio = (dateMs - firstDateMs) / totalDateSpanMs;
      final x = leftPad + chartWidth * dateRatio.clamp(0.0, 1.0);
      final normalized = (entries[i].weightKg - low) / range;
      final y = topPad + chartHeight * (1 - normalized.clamp(0.0, 1.0));
      pointOffsets.add(Offset(x, y));
    }

    final linePaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colorScheme.primary.withValues(alpha: 0.22),
          colorScheme.primary.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(leftPad, topPad, chartWidth, chartHeight));

    final path = _buildSmoothPath(pointOffsets);

    final areaPath = Path.from(path)
      ..lineTo(pointOffsets.last.dx, size.height - bottomPad)
      ..lineTo(pointOffsets.first.dx, size.height - bottomPad)
      ..close();

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()..color = colorScheme.primary;
    final pointStroke = Paint()
      ..color = colorScheme.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (final point in pointOffsets) {
      canvas.drawCircle(point, 4.5, pointPaint);
      canvas.drawCircle(point, 4.5, pointStroke);
    }
  }

  Path _buildSmoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length == 2) {
      path.lineTo(points.last.dx, points.last.dy);
      return path;
    }

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final dx = next.dx - current.dx;
      final cp1 = Offset(current.dx + dx * 0.35, current.dy);
      final cp2 = Offset(next.dx - dx * 0.35, next.dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.baselineWeight != baselineWeight ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.labelStyle != labelStyle;
  }
}
