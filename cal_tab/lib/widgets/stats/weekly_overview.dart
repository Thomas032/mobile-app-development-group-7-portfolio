import 'package:cal_tab/models/stats_snapshot.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';

class WeeklyOverview extends StatelessWidget {
  const WeeklyOverview({super.key, required this.snapshot});

  final StatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This week',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final useColumns = constraints.maxWidth >= 460;
              final metrics = [
                _MetricData(
                  icon: Icons.local_fire_department_rounded,
                  value: '${snapshot.averageCalories}',
                  label: 'Avg kcal',
                  detail: 'per day',
                  color: colors.primary,
                ),
                _MetricData(
                  icon: Icons.check_circle_rounded,
                  value: '${snapshot.targetDays}/7',
                  label: 'Target days',
                  detail: 'near goal',
                  color: const Color(0xFF34C759),
                ),
                _MetricData(
                  icon: Icons.bolt_rounded,
                  value: '${snapshot.streakDays}',
                  label: 'Streak',
                  detail: snapshot.streakDays == 1 ? 'day' : 'days',
                  color: const Color(0xFFFF9500),
                ),
              ];

              if (!useColumns) {
                return Column(
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      _MetricTile(data: metrics[i], horizontal: true),
                      if (i != metrics.length - 1)
                        Divider(
                          height: 24,
                          color: colors.outlineVariant.withValues(alpha: 0.6),
                        ),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < metrics.length; i++) ...[
                    Expanded(child: _MetricTile(data: metrics[i])),
                    if (i != metrics.length - 1)
                      SizedBox(
                        height: 64,
                        child: VerticalDivider(
                          color: colors.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.icon,
    required this.value,
    required this.label,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final String detail;
  final Color color;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data, this.horizontal = false});

  final _MetricData data;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final icon = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(data.icon, color: data.color, size: 21),
    );
    final copy = Column(
      crossAxisAlignment: horizontal
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          data.detail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );

    if (horizontal) {
      return Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(child: copy),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [icon, const SizedBox(height: 10), copy],
    );
  }
}
