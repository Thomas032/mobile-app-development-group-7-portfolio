import 'package:cal_tab/models/daily_nutrition_summary.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/widgets/shared/app_card.dart';
import 'package:cal_tab/widgets/home/macro_view.dart';
import 'package:cal_tab/widgets/home/micronutrient_view.dart';
import 'package:flutter/material.dart';

class SwipeableNutritionTile extends StatefulWidget {
  const SwipeableNutritionTile({
    super.key,
    required this.summary,
    required this.profile,
  });

  final DailyNutritionSummary summary;
  final UserProfile profile;

  @override
  State<SwipeableNutritionTile> createState() => _SwipeableNutritionTileState();
}

class _SwipeableNutritionTileState extends State<SwipeableNutritionTile> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 212,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: MacroView(
                    summary: widget.summary,
                    profile: widget.profile,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: MicronutrientView(summary: widget.summary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            final selected = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 7,
              width: selected ? 18 : 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: selected
                    ? colors.primary
                    : colors.outlineVariant.withValues(alpha: 0.8),
              ),
            );
          }),
        ),
      ],
    );
  }
}
