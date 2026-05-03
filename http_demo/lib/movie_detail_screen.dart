import 'package:flutter/material.dart';

import 'movie.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(movie.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (movie.posterUrl.isNotEmpty)
              _PosterImage(urls: movie.images),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${movie.year}  •  ${movie.genre}', style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  _RatingRow(imdbRating: movie.imdbRating, metascore: movie.metascore),
                  const SizedBox(height: 16),
                  _Section(label: 'Plot', body: movie.plot),
                  const SizedBox(height: 12),
                  _Section(label: 'Actors', body: movie.actors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterImage extends StatefulWidget {
  const _PosterImage({required this.urls});

  final List<String> urls;

  @override
  State<_PosterImage> createState() => _PosterImageState();
}

class _PosterImageState extends State<_PosterImage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (_index >= widget.urls.length) {
      return const SizedBox(height: 350, child: Center(child: Icon(Icons.broken_image, size: 64)));
    }
    return Image.network(
      widget.urls[_index],
      height: 350,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _index++);
        });
        return const SizedBox(height: 350, child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelLarge?.copyWith(color: Colors.grey[500], letterSpacing: 1.1)),
        const SizedBox(height: 4),
        Text(body, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.imdbRating, required this.metascore});

  final String imdbRating;
  final String metascore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RatingChip(label: 'IMDb', value: imdbRating, color: const Color(0xFFF5C518)),
        const SizedBox(width: 12),
        _RatingChip(label: 'Metascore', value: metascore, color: Colors.green),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color.darken())),
        ],
      ),
    );
  }
}

extension on Color {
  Color darken([double amount = 0.25]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
