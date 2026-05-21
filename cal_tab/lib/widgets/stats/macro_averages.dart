import 'package:cal_tab/models/stats_snapshot.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';

class MacroAveragesCard extends StatefulWidget {
  const MacroAveragesCard({super.key, required this.snapshot});

  final StatsSnapshot snapshot;

  @override
  State<MacroAveragesCard> createState() => _MacroAveragesCardState();
}

class _MacroAveragesCardState extends State<MacroAveragesCard> {
  bool _expandedMicro = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final macros = [
      _MacroStat(
        label: 'Protein',
        average: widget.snapshot.averageProteinGrams,
        target: widget.snapshot.profile.macroTargets.proteinGrams,
        color: const Color(0xFFFF9500),
      ),
      _MacroStat(
        label: 'Carbs',
        average: widget.snapshot.averageCarbsGrams,
        target: widget.snapshot.profile.macroTargets.carbsGrams,
        color: const Color(0xFF34C759),
      ),
      _MacroStat(
        label: 'Fat',
        average: widget.snapshot.averageFatGrams,
        target: widget.snapshot.profile.macroTargets.fatGrams,
        color: const Color(0xFFFF8E80),
      ),
    ];

    final microStats = [
      _MicroStat(
        label: 'Fiber',
        average: widget.snapshot.averageFiberGrams,
        unit: 'g',
        color: const Color(0xFF6D7B6B),
      ),
      _MicroStat(
        label: 'Sugar',
        average: widget.snapshot.averageSugarGrams,
        unit: 'g',
        color: const Color(0xFFFF5252),
      ),
      _MicroStat(
        label: 'Sodium',
        average: widget.snapshot.averageSodiumMilligrams,
        unit: 'mg',
        color: const Color(0xFF536DFE),
      ),
      _MicroStat(
        label: 'Sat. Fat',
        average: widget.snapshot.averageSaturatedFatGrams,
        unit: 'g',
        color: const Color(0xFFFF8E80),
      ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macro averages',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            widget.snapshot.loggedDays == 0
                ? 'Logged-day avg'
                : 'Across ${widget.snapshot.loggedDays} logged days',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < macros.length; i++) ...[
            _MacroAverageRow(stat: macros[i]),
            if (i != macros.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              setState(() => _expandedMicro = !_expandedMicro);
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Micronutrients',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
                Icon(
                  _expandedMicro
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: colors.primary,
                ),
              ],
            ),
          ),
          if (_expandedMicro) ...[
            const SizedBox(height: 14),
            for (var i = 0; i < microStats.length; i++) ...[
              _MicroAverageRow(stat: microStats[i]),
              if (i != microStats.length - 1) const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _MacroStat {
  const _MacroStat({
    required this.label,
    required this.average,
    required this.target,
    required this.color,
  });

  final String label;
  final double average;
  final double target;
  final Color color;
}

class _MicroStat {
  const _MicroStat({
    required this.label,
    required this.average,
    required this.unit,
    required this.color,
  });

  final String label;
  final double average;
  final String unit;
  final Color color;
}

class _MacroAverageRow extends StatelessWidget {
  const _MacroAverageRow({required this.stat});

  final _MacroStat stat;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = stat.target <= 0
        ? 0.0
        : (stat.average / stat.target).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stat.label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${stat.average.round()}/${stat.target.round()}g',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            key: Key('stats_macro_${stat.label.toLowerCase()}_progress'),
            value: progress,
            minHeight: 8,
            color: stat.color,
            backgroundColor: stat.color.withValues(alpha: 0.14),
          ),
        ),
      ],
    );
  }
}

class _MicroAverageRow extends StatelessWidget {
  const _MicroAverageRow({required this.stat});

  final _MicroStat stat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: stat.color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: stat.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            stat.label,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '${stat.average.toStringAsFixed(1)}${stat.unit}',
          style: textTheme.bodySmall?.copyWith(
            color: stat.color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
