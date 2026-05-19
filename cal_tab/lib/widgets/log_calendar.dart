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

  /// Large symmetric range; the PageView is virtually infinite for the
  /// purposes of this app — the user won't realistically swipe past it.
  static const int _initialPage = 5000;

  @override
  State<LogCalendar> createState() => _LogCalendarState();
}

class _LogCalendarState extends State<LogCalendar> {
  late final PageController _pageController;
  late DateTime _anchorMonday;

  @override
  void initState() {
    super.initState();
    _anchorMonday = _startOfWeek(widget.selectedDate);
    _pageController = PageController(initialPage: LogCalendar._initialPage);
  }

  @override
  void didUpdateWidget(covariant LogCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      final newMonday = _startOfWeek(widget.selectedDate);
      if (!_isSameDay(newMonday, _anchorMonday)) {
        final weekDelta = _weekDelta(_anchorMonday, newMonday);
        final targetPage = LogCalendar._initialPage + weekDelta;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_pageController.hasClients) return;
          final current = _pageController.page?.round() ??
              LogCalendar._initialPage;
          if ((current - targetPage).abs() <= 1) {
            _pageController.animateToPage(
              targetPage,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
            );
          } else {
            _pageController.jumpToPage(targetPage);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayNorm = normalizeLogDate(widget.today);
    final selectedNorm = normalizeLogDate(widget.selectedDate);

    return SizedBox(
      height: 82,
      child: PageView.builder(
        key: const Key('home_calendar_pager'),
        controller: _pageController,
        itemBuilder: (context, pageIndex) {
          final weekDelta = pageIndex - LogCalendar._initialPage;
          final weekStart = _anchorMonday.add(Duration(days: weekDelta * 7));
          return _WeekStrip(
            weekStart: weekStart,
            today: todayNorm,
            selectedDate: selectedNorm,
            logState: widget.logState,
            profile: widget.profile,
            onDateSelected: widget.onDateSelected,
          );
        },
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.weekStart,
    required this.today,
    required this.selectedDate,
    required this.logState,
    required this.profile,
    required this.onDateSelected,
  });

  final DateTime weekStart;
  final DateTime today;
  final DateTime selectedDate;
  final DailyLogState logState;
  final UserProfile profile;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _CalendarDayChip(
                  date: day,
                  status: _CalendarDayStatus.from(
                    day: day,
                    today: today,
                    logState: logState,
                    profile: profile,
                  ),
                  isSelected: _isSameDay(day, selectedDate),
                  isToday: _isSameDay(day, today),
                  onTap: () => onDateSelected(day),
                ),
              ),
            ),
        ],
      ),
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
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final _CalendarDayStatus status;
  final bool isSelected;
  final bool isToday;
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
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday ? fgColor : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

DateTime _startOfWeek(DateTime date) {
  final normalized = normalizeLogDate(date);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
}

int _weekDelta(DateTime fromMonday, DateTime toMonday) {
  final from = DateTime.utc(fromMonday.year, fromMonday.month, fromMonday.day);
  final to = DateTime.utc(toMonday.year, toMonday.month, toMonday.day);
  return to.difference(from).inDays ~/ 7;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
