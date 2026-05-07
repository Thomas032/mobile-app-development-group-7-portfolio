import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:flutter/material.dart';

class LogCalendar extends StatefulWidget {
  const LogCalendar({
    super.key,
    required this.logState,
    required this.profile,
    required this.selectedDate,
    required this.today,
    required this.onDateSelected,
  });

  final DailyLogState logState;
  final UserProfile profile;
  final DateTime selectedDate;
  final DateTime today;
  final ValueChanged<DateTime> onDateSelected;

  static const _rangeBeforeToday = 14;
  static const _rangeAfterToday = 14;
  static const _dayExtent = 58.0;

  @override
  State<LogCalendar> createState() => _LogCalendarState();
}

class _LogCalendarState extends State<LogCalendar> {
  late final ScrollController _scrollController;
  late DateTime _anchorDate;

  @override
  void initState() {
    super.initState();
    final selectedDate = normalizeLogDate(widget.selectedDate);
    final today = normalizeLogDate(widget.today);
    _anchorDate = _isDateInRangeForAnchor(selectedDate, today)
        ? today
        : selectedDate;
    _scrollController = ScrollController(
      initialScrollOffset: _offsetForDate(selectedDate),
    );
  }

  @override
  void didUpdateWidget(covariant LogCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final selectedDate = normalizeLogDate(widget.selectedDate);
    if (!_isDateInRenderedRange(selectedDate)) {
      _anchorDate = selectedDate;
    }

    if (!_isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToSelectedDate();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayNorm = normalizeLogDate(widget.today);
    final selectedNorm = normalizeLogDate(widget.selectedDate);
    final days = List.generate(
      LogCalendar._rangeBeforeToday + LogCalendar._rangeAfterToday + 1,
      (i) => _anchorDate.add(Duration(days: i - LogCalendar._rangeBeforeToday)),
    );

    return SizedBox(
      height: 82,
      child: ListView.builder(
        key: const Key('home_calendar_list'),
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemExtent: LogCalendar._dayExtent,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final status = _CalendarDayStatus.from(
            day: day,
            today: todayNorm,
            logState: widget.logState,
            profile: widget.profile,
          );

          return Align(
            alignment: Alignment.centerLeft,
            child: _CalendarDayChip(
              date: day,
              status: status,
              isSelected: _isSameDay(day, selectedNorm),
              onTap: () => widget.onDateSelected(day),
            ),
          );
        },
      ),
    );
  }

  bool _isDateInRenderedRange(DateTime date) {
    return _isDateInRangeForAnchor(date, _anchorDate);
  }

  bool _isDateInRangeForAnchor(DateTime date, DateTime anchor) {
    final dayOffset = _dayDelta(anchor, date);
    return dayOffset >= -LogCalendar._rangeBeforeToday &&
        dayOffset <= LogCalendar._rangeAfterToday;
  }

  double _offsetForDate(DateTime date) {
    const leadingVisibleDays = 2;
    final firstRenderedDate = _anchorDate.subtract(
      const Duration(days: LogCalendar._rangeBeforeToday),
    );
    final index = _dayDelta(firstRenderedDate, date);
    final rawOffset = (index - leadingVisibleDays) * LogCalendar._dayExtent;
    return rawOffset < 0 ? 0 : rawOffset;
  }

  void _scrollToSelectedDate() {
    if (!_scrollController.hasClients) {
      return;
    }

    final maxOffset = _scrollController.position.maxScrollExtent;
    final targetOffset = _offsetForDate(
      widget.selectedDate,
    ).clamp(0.0, maxOffset).toDouble();
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }
}

enum _CalendarDayStatus {
  goalReached,
  belowGoal,
  emptyOrFuture;

  static _CalendarDayStatus from({
    required DateTime day,
    required DateTime today,
    required DailyLogState logState,
    required UserProfile profile,
  }) {
    final normalized = normalizeLogDate(day);
    if (normalized.isAfter(today)) {
      return _CalendarDayStatus.emptyOrFuture;
    }

    final entries = logState.entriesForDate(normalized);
    if (entries.isEmpty) {
      return _CalendarDayStatus.emptyOrFuture;
    }

    final summary = logState.summaryFor(date: normalized, profile: profile);
    return summary.caloriesConsumed >= profile.calorieGoal
        ? _CalendarDayStatus.goalReached
        : _CalendarDayStatus.belowGoal;
  }

  Color color(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return switch (this) {
      _CalendarDayStatus.goalReached => const Color(0xFF34C759),
      _CalendarDayStatus.belowGoal => const Color(0xFFFF9500),
      _CalendarDayStatus.emptyOrFuture => colors.surfaceContainerHigh,
    };
  }

  Color foregroundColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return switch (this) {
      _CalendarDayStatus.goalReached ||
      _CalendarDayStatus.belowGoal => Colors.white,
      _CalendarDayStatus.emptyOrFuture => colors.onSurfaceVariant,
    };
  }
}

class _CalendarDayChip extends StatelessWidget {
  const _CalendarDayChip({
    required this.date,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final _CalendarDayStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bgColor = status.color(context);
    final fgColor = status.foregroundColor(context);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: Key('calendar_day_${logDateKey(date)}'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          key: Key('calendar_day_status_${logDateKey(date)}'),
          width: 50,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _weekdays[date.weekday - 1],
                style: textTheme.labelSmall?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: textTheme.titleMedium?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

int _dayDelta(DateTime start, DateTime end) {
  final startUtc = DateTime.utc(start.year, start.month, start.day);
  final endUtc = DateTime.utc(end.year, end.month, end.day);
  return endUtc.difference(startUtc).inDays;
}
