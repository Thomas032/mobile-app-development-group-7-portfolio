import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:http_demo/movie.dart';
import 'package:http_demo/movie_detail_screen.dart';

Movie _avatar() => Movie.fromJson(<String, dynamic>{
      'Title': 'Avatar',
      'Year': '2009',
      'Genre': 'Action, Adventure, Fantasy',
      'Director': 'James Cameron',
      'Actors':
          'Sam Worthington, Zoe Saldana, Sigourney Weaver, Stephen Lang',
      'Plot':
          'A paraplegic marine dispatched to the moon Pandora on a unique mission becomes torn between following his orders and protecting the world he feels is his home.',
      'Metascore': '83',
      'imdbRating': '7.9',
      'Images': <String>[],
    });

Movie _iAmLegend() => Movie.fromJson(<String, dynamic>{
      'Title': 'I Am Legend',
      'Year': '2007',
      'Genre': 'Drama, Horror, Sci-Fi',
      'Director': 'Francis Lawrence',
      'Actors':
          'Will Smith, Alice Braga, Charlie Tahan, Salli Richardson-Whitfield',
      'Plot':
          'Years after a plague kills most of humanity and transforms the rest into monsters, the sole survivor in New York City struggles valiantly to find a cure.',
      'Metascore': '65',
      'imdbRating': '7.2',
      'Images': <String>[],
    });

class _TestHome extends StatelessWidget {
  const _TestHome({required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movies')),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return ListTile(
            title: Text(movie.title),
            subtitle: Text(movie.director),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailScreen(movie: movie),
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  group('Main → Detail navigation', () {
    testWidgets('tapping a list tile pushes the MovieDetailScreen',
        (tester) async {
      final movies = [_avatar(), _iAmLegend()];

      await tester.pumpWidget(MaterialApp(home: _TestHome(movies: movies)));

      expect(find.text('Avatar'), findsOneWidget);
      expect(find.text('I Am Legend'), findsOneWidget);
      expect(find.byType(MovieDetailScreen), findsNothing);

      await tester.tap(find.text('Avatar'));
      await tester.pumpAndSettle();

      expect(find.byType(MovieDetailScreen), findsOneWidget);
      expect(find.textContaining('2009'), findsWidgets);
      expect(find.textContaining('Action, Adventure, Fantasy'), findsWidgets);
      expect(find.textContaining('paraplegic marine'), findsOneWidget);
    });

    testWidgets('back button returns to the movie list', (tester) async {
      final movies = [_avatar()];

      await tester.pumpWidget(MaterialApp(home: _TestHome(movies: movies)));

      await tester.tap(find.text('Avatar'));
      await tester.pumpAndSettle();
      expect(find.byType(MovieDetailScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(MovieDetailScreen), findsNothing);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Avatar'), findsOneWidget);
    });

    testWidgets('tapping different tiles opens the matching detail screen',
        (tester) async {
      final movies = [_avatar(), _iAmLegend()];

      await tester.pumpWidget(MaterialApp(home: _TestHome(movies: movies)));

      await tester.tap(find.text('I Am Legend'));
      await tester.pumpAndSettle();

      expect(find.byType(MovieDetailScreen), findsOneWidget);
      expect(find.textContaining('Will Smith'), findsWidgets);
      expect(find.textContaining('Drama, Horror, Sci-Fi'), findsWidgets);
      expect(find.textContaining('plague'), findsOneWidget);
    });
  });
}
