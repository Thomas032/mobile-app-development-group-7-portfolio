import 'package:flutter/material.dart';
import '../widgets/info_card.dart';
import 'menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Authentic Italian cuisine in the heart of the city. '
                    'We use only fresh, locally sourced ingredients.',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
