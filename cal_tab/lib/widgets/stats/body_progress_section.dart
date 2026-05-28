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
            _AddEntryForm(profile: profile),
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

class _AddEntryForm extends ConsumerStatefulWidget {
  const _AddEntryForm({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_AddEntryForm> createState() => _AddEntryFormState();
}

class _AddEntryFormState extends ConsumerState<_AddEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weightController.text = widget.profile.weightKg.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add progress entry',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const Key('body_progress_date_button'),
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text('Date: ${formatLongDate(_selectedDate)}'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('body_progress_weight_field'),
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight',
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('body_progress_waist_field'),
              controller: _waistController,
              decoration: const InputDecoration(
                labelText: 'Waist',
                suffixText: 'cm',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validateOptionalNumber,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('body_progress_note_field'),
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 2,
              minLines: 1,
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('save_body_progress_button'),
              onPressed: _isSaving ? null : _saveEntry,
              child: Text(_isSaving ? 'Saving…' : 'Save'),
            ),
            const SizedBox(height: 8),
            Text(
              'Track changes over time with quick weight and waist check-ins.',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _selectedDate = picked);
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final weight = double.parse(_weightController.text.trim());
      final waistText = _waistController.text.trim();
      final noteText = _noteController.text.trim();

      await ref
          .read(bodyProgressControllerProvider.notifier)
          .addEntry(
            BodyProgressEntry(
              id: 'body-progress-${DateTime.now().microsecondsSinceEpoch}',
              date: _selectedDate,
              weightKg: weight,
              waistCm: waistText.isEmpty ? null : double.parse(waistText),
              note: noteText.isEmpty ? null : noteText,
            ),
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _selectedDate = DateTime.now();
        _weightController.clear();
        _waistController.clear();
        _noteController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Body progress entry saved.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
    }
  }

  String? _validatePositiveNumber(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter a value above 0';
    }
    return null;
  }

  String? _validateOptionalNumber(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return 'Enter a value above 0';
    }
    return null;
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
    final delta = currentWeight - profile.weightKg;

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
                : '${_deltaLabel(delta)} since starting point of ${profile.weightKg.toStringAsFixed(1)} kg',
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
              'No progress entries yet. Save your first check-in above.',
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
    try {
      await ref
          .read(bodyProgressControllerProvider.notifier)
          .removeEntry(entry.id);
    } catch (_) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Progress entry removed.')));
  }
}

String _deltaLabel(double delta) {
  if (delta.abs() < 0.05) {
    return 'No change';
  }
  final prefix = delta > 0 ? '+' : '';
  return '$prefix${delta.toStringAsFixed(1)} kg';
}
