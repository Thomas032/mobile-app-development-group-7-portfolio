import 'package:flutter/material.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.streak,
    required this.date,
    required this.onDatePressed,
  });

  final int streak;
  final DateTime date;
  final VoidCallback onDatePressed;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final dateLabel = '${_months[date.month - 1]} ${date.day}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          PillBadge(
            key: const Key('streak_badge'),
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF9500),
            label: '$streak',
          ),
          Expanded(
            child: Center(
              child: Text(
                'CalTab',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          PillBadge(
            key: const Key('date_badge'),
            icon: Icons.calendar_today_rounded,
            iconColor: colors.primary,
            label: dateLabel,
            tooltip: 'Choose date',
            onTap: onDatePressed,
          ),
        ],
      ),
    );
  }
}

class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final badge = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (tooltip == null) {
      return badge;
    }

    return Tooltip(message: tooltip!, child: badge);
  }
}
