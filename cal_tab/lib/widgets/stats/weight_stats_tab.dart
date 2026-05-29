import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/widgets/stats/body_progress_section.dart';
import 'package:flutter/material.dart';

class WeightStatsTab extends StatelessWidget {
  const WeightStatsTab({super.key, required this.profile});

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
