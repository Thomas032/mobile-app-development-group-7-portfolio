import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/screens/ai_screen.dart';
import 'package:cal_tab/screens/home_screen.dart';
import 'package:cal_tab/screens/settings_screen.dart';
import 'package:cal_tab/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      HomeScreen(profile: widget.profile),
      const StatsScreen(),
      const AiScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: destinations),
      bottomNavigationBar: _MainBottomBar(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) => setState(() => _selectedIndex = index),
        onAddFood: () => context.pushNamed('add-food'),
      ),
    );
  }
}

class _MainBottomBar extends StatelessWidget {
  const _MainBottomBar({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onAddFood,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddFood;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 88 + bottomInset,
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.96),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              _BottomTabButton(
                key: const Key('home_tab_button'),
                index: 0,
                selectedIndex: selectedIndex,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                onTap: onTabSelected,
              ),
              _BottomTabButton(
                key: const Key('stats_tab_button'),
                index: 1,
                selectedIndex: selectedIndex,
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                label: 'Stats',
                onTap: onTabSelected,
              ),
              const SizedBox(width: 96),
              _BottomTabButton(
                key: const Key('ai_tab_button'),
                index: 2,
                selectedIndex: selectedIndex,
                icon: Icons.auto_awesome_outlined,
                selectedIcon: Icons.auto_awesome,
                label: 'AI',
                onTap: onTabSelected,
              ),
              _BottomTabButton(
                key: const Key('settings_tab_button'),
                index: 3,
                selectedIndex: selectedIndex,
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: 'Settings',
                onTap: onTabSelected,
              ),
            ],
          ),
          Transform.translate(
            child: SizedBox.square(
              dimension: 64,
              child: FloatingActionButton(
                key: const Key('open_add_food_button'),
                tooltip: 'Add food',
                onPressed: onAddFood,
                child: const Icon(Icons.add, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomTabButton extends StatelessWidget {
  const _BottomTabButton({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color:
                          isSelected ? colors.primary : colors.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
