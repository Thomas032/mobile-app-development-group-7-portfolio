import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/widgets/shared/app_card.dart';
import 'package:cal_tab/widgets/home/meal_sections.dart';
import 'package:cal_tab/widgets/home/swipeable_nutrition_tile.dart';
import 'package:cal_tab/widgets/home/top_bar.dart';
import 'package:cal_tab/widgets/home/log_calendar.dart';
import 'package:cal_tab/widgets/shared/section_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logState = ref.watch(dailyLogControllerProvider);
    final today = DateTime.now();
    final selectedDate = ref.watch(selectedLogDateProvider);
    final summary = logState.summaryFor(date: selectedDate, profile: profile);
    final selectedEntries = logState.entriesForDate(selectedDate);
    final streak = logState.streakDays(today);

    return SafeArea(
      child: Column(
        children: [
          HomeTopBar(
            streak: streak,
            date: selectedDate,
            onDatePressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(today.year - 5),
                lastDate: DateTime(today.year + 5),
                currentDate: today,
              );

              if (pickedDate != null && context.mounted) {
                ref.read(selectedLogDateProvider.notifier).select(pickedDate);
              }
            },
          ),
          Expanded(
            child: ListView(
              key: const Key('home_main_scroll'),
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 104),
              children: [
                LogCalendar(
                  logState: logState,
                  profile: profile,
                  selectedDate: selectedDate,
                  today: today,
                  onDateSelected: ref
                      .read(selectedLogDateProvider.notifier)
                      .select,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SwipeableNutritionTile(
                        summary: summary,
                        profile: profile,
                      ),
                      const SizedBox(height: 24),
                      const SectionLabel(text: 'Meals'),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: MealAccordions(
                          entries: selectedEntries,
                          date: selectedDate,
                        ),
                      ),
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
