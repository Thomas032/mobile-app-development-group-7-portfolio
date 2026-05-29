import 'package:cal_tab/models/stats_snapshot.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/widgets/stats/calorie_trend.dart';
import 'package:cal_tab/widgets/stats/macro_averages.dart';
import 'package:cal_tab/widgets/stats/meal_consistency.dart';
import 'package:cal_tab/widgets/stats/weekly_overview.dart';
import 'package:flutter/material.dart';

class NutritionStatsTab extends StatelessWidget {
  const NutritionStatsTab({
    super.key,
    required this.profile,
    required this.snapshot,
  });

  final UserProfile profile;
  final StatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        return ListView(
          key: const Key('nutrition_stats_scroll'),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 104),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WeeklyOverview(snapshot: snapshot),
                    const SizedBox(height: 20),
                    CalorieTrendCard(snapshot: snapshot),
                    const SizedBox(height: 20),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MacroAveragesCard(snapshot: snapshot),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MealConsistencyCard(snapshot: snapshot),
                          ),
                        ],
                      )
                    else ...[
                      MacroAveragesCard(snapshot: snapshot),
                      const SizedBox(height: 20),
                      MealConsistencyCard(snapshot: snapshot),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
