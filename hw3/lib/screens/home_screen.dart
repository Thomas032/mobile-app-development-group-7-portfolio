import 'package:flutter/material.dart';
import '../widgets/info_card.dart';
import 'menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const Color _textMuted = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/la_travola.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to La Travola',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Authentic Italian cuisine in the heart of the city. '
                    'We use only fresh, locally sourced ingredients.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      InfoCard(
                        icon: Icons.access_time,
                        label: 'Hours',
                        value: 'Mon–Sun\n11:00–22:00',
                      ),
                      const SizedBox(width: 12),
                      InfoCard(
                        icon: Icons.location_on,
                        label: 'Address',
                        value: 'Hauptstr. 12\nWürzburg',
                      ),
                      const SizedBox(width: 12),
                      InfoCard(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: '+49 931\n123456',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MenuScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book),
                      label: const Text('View Menu'),
                    ),
                  ),

                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.facebook, size: 22, color: _textMuted),
                      SizedBox(width: 18),
                      Icon(Icons.camera_alt_outlined,
                          size: 22, color: _textMuted),
                      SizedBox(width: 18),
                      Icon(Icons.play_circle_fill,
                          size: 22, color: _textMuted),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '© 2022 La Travola.corp. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
