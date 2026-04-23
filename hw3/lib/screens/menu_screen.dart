import 'package:flutter/material.dart';
import '../models/dish.dart';
import 'dish_detail_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: ListView.builder(
        itemCount: menu.keys.length,
        itemBuilder: (context, categoryIndex) {
          final category = menu.keys.elementAt(categoryIndex);
          final dishes = menu[category]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF8B4513),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),

              ...dishes.map(
                (dish) => ListTile(
                  title: Text(dish.name),
                  subtitle: Text(dish.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '€${dish.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DishDetailScreen(dish: dish),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
