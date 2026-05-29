import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/body_progress_provider.dart';
import 'package:cal_tab/utils/date_formatting.dart';
import 'package:cal_tab/widgets/shared/app_card.dart';
import 'package:cal_tab/widgets/shared/section_card.dart';
import 'package:cal_tab/widgets/stats/weight_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BodyProgressSection extends ConsumerWidget {
  const BodyProgressSection({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(bodyProgressControllerProvider);

    return SectionCard(
      title: 'Body Progress',
      icon: Icons.monitor_weight_outlined,
      child: entriesAsync.when(
        data: (entries) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CurrentWeightCard(profile: profile, entries: entries),
            const SizedBox(height: 16),
            WeightChartCard(
              baselineWeightKg: profile.weightKg,
              entries: entries,
            ),
            const SizedBox(height: 16),
            _HistoryCard(entries: entries),
          ],
        ),
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => Text('Failed to load progress: $error'),
      ),
    );
  }
}

class _CurrentWeightCard extends StatelessWidget {
  const _CurrentWeightCard({required this.profile, required this.entries});

  final UserProfile profile;
  final List<BodyProgressEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final latest = entries.isEmpty ? null : entries.first;
    final currentWeight = latest?.weightKg ?? profile.weightKg;
    final baselineWeight = entries.isEmpty
        ? profile.weightKg
        : entries.last.weightKg;
    final delta = currentWeight - baselineWeight;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current weight',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentWeight.toStringAsFixed(1),
                key: const Key('body_progress_current_weight'),
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 6),
                child: Text(
                  'kg',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            latest == null
                ? 'Using your onboarding weight until you log your first progress entry.'
                : '${_deltaLabel(delta)} since starting point of ${baselineWeight.toStringAsFixed(1)} kg',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entries});

  final List<BodyProgressEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(
              'No weight entries yet.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  _HistoryRow(entry: entries[i]),
                  if (i != entries.length - 1)
                    Divider(
                      height: 24,
                      color: colors.outlineVariant.withValues(alpha: 0.6),
                    ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({required this.entry});

  final BodyProgressEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            key: Key('body_progress_history_${entry.id}'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatLongDate(entry.date),
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.weightKg.toStringAsFixed(1)} kg'
                '${entry.waistCm == null ? '' : ' • ${entry.waistCm!.toStringAsFixed(1)} cm waist'}',
                style: textTheme.bodyMedium,
              ),
              if (entry.note != null && entry.note!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  entry.note!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          tooltip: 'Delete entry',
          onPressed: () => _delete(context, ref),
          icon: Icon(Icons.delete_outline, color: colors.error),
        ),
      ],
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    int? newCalorieGoal;
    try {
      newCalorieGoal = await ref
          .read(bodyProgressControllerProvider.notifier)
          .removeEntry(entry.id);
    } catch (_) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final message = newCalorieGoal == null
        ? 'Progress entry removed.'
        : 'Entry removed — calorie target is now $newCalorieGoal kcal.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

String _deltaLabel(double delta) {
  if (delta.abs() < 0.05) {
    return 'No change';
  }
  final prefix = delta > 0 ? '+' : '';
  return '$prefix${delta.toStringAsFixed(1)} kg';
}
