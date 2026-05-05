import 'package:cal_tab/screens/placeholder_feature_screen.dart';
import 'package:flutter/material.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureScreen(
      title: 'AI',
      icon: Icons.auto_awesome_outlined,
      description:
          "The assistant will use your local profile and today's intake after you add your own API key.",
    );
  }
}
