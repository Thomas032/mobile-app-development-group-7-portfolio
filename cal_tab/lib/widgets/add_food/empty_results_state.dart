import 'package:flutter/material.dart';

class EmptyResultsState extends StatelessWidget {
  const EmptyResultsState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No foods found.',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}
