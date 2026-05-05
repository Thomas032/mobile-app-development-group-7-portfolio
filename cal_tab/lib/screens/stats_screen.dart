import 'package:cal_tab/screens/placeholder_feature_screen.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureScreen(
      title: 'Stats',
      icon: Icons.show_chart,
      description:
          'Daily history, weekly trends, macro progress, and meal consistency will appear here.',
    );
  }
}
