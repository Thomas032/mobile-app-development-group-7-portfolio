import 'package:flutter/material.dart';

class FoodThumbnail extends StatelessWidget {
  const FoodThumbnail({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: colors.surfaceContainerHigh,
        child: SizedBox.square(
          dimension: 58,
          child: imageUrl == null
              ? Icon(Icons.restaurant, color: colors.onSurfaceVariant)
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                      ),
                      child: const SizedBox.expand(),
                    );
                  },
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.restaurant, color: colors.onSurfaceVariant),
                ),
        ),
      ),
    );
  }
}
