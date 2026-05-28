import 'dart:math' as math;

import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/body_progress_provider.dart';
import 'package:cal_tab/utils/date_formatting.dart';
import 'package:cal_tab/widgets/shared/app_card.dart';
import 'package:cal_tab/widgets/shared/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BodyProgressSection extends ConsumerStatefulWidget {
  const BodyProgressSection({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<BodyProgressSection> createState() =>
      _BodyProgressSectionState();
}

class _BodyProgressSectionState extends ConsumerState<BodyProgressSection> {
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
    final entriesAsync = ref.watch(bodyProgressControllerProvider);

    return SectionCard(
      title: 'Body Progress',
      icon: Icons.monitor_weight_outlined,
      child: entriesAsync.when(
        data: (entries) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CurrentWeightCard(profile: widget.profile, entries: entries),
            const SizedBox(height: 16),
            _WeightChartCard(profile: widget.profile, entries: entries),
            const SizedBox(height: 16),
            _buildForm(context),
            const SizedBox(height: 16),
            _HistoryCard(entries: entries, onDelete: _deleteEntry),
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

  Widget _buildForm(BuildContext context) {
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

  Future<void> _deleteEntry(BodyProgressEntry entry) async {
    await ref
        .read(bodyProgressControllerProvider.notifier)
        .removeEntry(entry.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Progress entry removed.')));
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

class _WeightChartCard extends StatelessWidget {
  const _WeightChartCard({required this.profile, required this.entries});

  final UserProfile profile;
  final List<BodyProgressEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final sortedAsc = entries.reversed.toList(growable: false);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight over time',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
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
                  baselineWeight: profile.weightKg,
                  colorScheme: colors,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            formatShortDate(sortedAsc.first.date),
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatShortDate(sortedAsc.last.date),
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entries, required this.onDelete});

  final List<BodyProgressEntry> entries;
  final Future<void> Function(BodyProgressEntry entry) onDelete;

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
                  _HistoryRow(entry: entries[i], onDelete: onDelete),
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

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.onDelete});

  final BodyProgressEntry entry;
  final Future<void> Function(BodyProgressEntry entry) onDelete;

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => onDelete(entry),
          icon: Icon(Icons.delete_outline, color: colors.error),
        ),
      ],
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({
    required this.entries,
    required this.baselineWeight,
    required this.colorScheme,
  });

  final List<BodyProgressEntry> entries;
  final double baselineWeight;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 12.0;
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
    }

    final pointOffsets = <Offset>[];
    for (var i = 0; i < entries.length; i++) {
      final x = leftPad + chartWidth * i / (entries.length - 1);
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

    final path = Path()..moveTo(pointOffsets.first.dx, pointOffsets.first.dy);
    for (final point in pointOffsets.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

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

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.baselineWeight != baselineWeight ||
        oldDelegate.colorScheme != colorScheme;
  }
}

String _deltaLabel(double delta) {
  if (delta.abs() < 0.05) {
    return 'No change';
  }
  final prefix = delta > 0 ? '+' : '';
  return '$prefix${delta.toStringAsFixed(1)} kg';
}
