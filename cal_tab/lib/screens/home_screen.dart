import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logState = ref.watch(dailyLogControllerProvider);
    final todayEntries = logState.entriesForDate(DateTime.now());
    final summary = logState.summaryFor(date: DateTime.now(), profile: profile);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 104),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.caloriesConsumed} kcal logged',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              children: [
                SizedBox.square(
                  dimension: 172,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: summary.calorieProgress
                            .clamp(0.0, 1.0)
                            .toDouble(),
                        strokeWidth: 16,
                        strokeCap: StrokeCap.round,
                        backgroundColor: colors.primary.withValues(alpha: 0.10),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${summary.caloriesLeft}',
                              key: const Key('calories_left_value'),
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'kcal left',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Daily target ${profile.calorieGoal} kcal',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children: [
              _MacroTile(
                label: 'Protein',
                consumed: summary.proteinConsumedGrams,
                target: profile.macroTargets.proteinGrams,
                color: const Color(0xFFFF9500),
              ),
              _MacroTile(
                label: 'Carbs',
                consumed: summary.carbsConsumedGrams,
                target: profile.macroTargets.carbsGrams,
                color: const Color(0xFF34C759),
              ),
              _MacroTile(
                label: 'Fat',
                consumed: summary.fatConsumedGrams,
                target: profile.macroTargets.fatGrams,
                color: const Color(0xFFFF8E80),
              ),
              _MacroTile(
                label: 'Fiber',
                consumed: summary.fiberConsumedGrams,
                target: profile.macroTargets.fiberGrams,
                color: const Color(0xFF6D7B6B),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meals',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (todayEntries.isEmpty)
                  Text(
                    'No food logged yet.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  )
                else
                  for (final entry in todayEntries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.foodItem.name),
                                Text(
                                  entry.mealType.label,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text('${entry.calories} kcal'),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
  });

  final String label;
  final double consumed;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = target <= 0
        ? 0.0
        : (consumed / target).clamp(0.0, 1.0).toDouble();
    final percentage = (progress * 100).round();

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.14),
                ),
                Center(
                  child: Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${consumed.round()}/${target.round()}g',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
