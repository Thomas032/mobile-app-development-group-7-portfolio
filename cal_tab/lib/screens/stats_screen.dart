import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/stats_provider.dart';
import 'package:cal_tab/widgets/stats/nutrition_stats_tab.dart';
import 'package:cal_tab/widgets/stats/weight_stats_tab.dart';
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
                NutritionStatsTab(
                  profile: widget.profile,
                  snapshot: snapshot,
                ),
                WeightStatsTab(profile: widget.profile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
