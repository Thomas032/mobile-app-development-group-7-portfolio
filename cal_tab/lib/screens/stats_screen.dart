import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/models/stats_snapshot.dart';
import 'package:cal_tab/providers/stats_provider.dart';
import 'package:cal_tab/widgets/stats/body_progress_section.dart';
import 'package:cal_tab/widgets/stats/calorie_trend.dart';
import 'package:cal_tab/widgets/stats/macro_averages.dart';
import 'package:cal_tab/widgets/stats/meal_consistency.dart';
import 'package:cal_tab/widgets/stats/stats_header.dart';
import 'package:cal_tab/widgets/stats/weekly_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(weeklyStatsProvider(widget.profile));
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Stats',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Nutrition'),
                      Tab(text: 'Weight'),
                    ],
                    dividerHeight: 0,
                    tabAlignment: TabAlignment.fill,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: colors.primaryContainer,
                    ),
                    labelColor: colors.onPrimaryContainer,
                    unselectedLabelColor: colors.onSurfaceVariant,
                    labelStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Nutrition Stats Tab
                _NutritionStatsTab(profile: widget.profile, snapshot: snapshot),
                // Weight Stats Tab
                _WeightStatsTab(profile: widget.profile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionStatsTab extends StatelessWidget {
  const _NutritionStatsTab({required this.profile, required this.snapshot});

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

class _WeightStatsTab extends StatelessWidget {
  const _WeightStatsTab({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('weight_stats_scroll'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 104),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: BodyProgressSection(profile: profile),
          ),
        ),
      ],
    );
  }
}
