import 'package:flutter/material.dart';

class CalorieStatusBar extends StatelessWidget {
  const CalorieStatusBar({
    super.key,
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalized = progress.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: normalized,
        minHeight: 10,
        backgroundColor: color.withValues(alpha: 0.20),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
