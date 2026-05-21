import 'package:cal_tab/widgets/shared/section_card.dart';
import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  static const String _appVersion = '1.0.0';
  static const List<String> _teamMembers = [
    'Tomáš Bartoš',
    'Christian Model',
    'Manuel Stöth',
    'Tai Mai',
    'Steffen Krutzsch',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SectionCard(
      title: 'About',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CalTab',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            'Version $_appVersion',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A privacy-first calorie and macro tracker built for the Mobile '
            'Applications module (THWS / TAMK, 2026).',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Team',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final name in _teamMembers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• $name', style: textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}
