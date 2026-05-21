import 'package:flutter/material.dart';

class StepBadge extends StatelessWidget {
  const StepBadge({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$current/$total',
        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
