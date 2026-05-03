import 'package:flutter_test/flutter_test.dart';
import 'package:http_demo/movie.dart';

void main() {
  final avatarJson = <String, dynamic>{
    'Title': 'Avatar',
    'Year': '2009',
    'Genre': 'Action, Adventure, Fantasy',
    'Director': 'James Cameron',
    'Actors': 'Sam Worthington, Zoe Saldana, Sigourney Weaver, Stephen Lang',
    'Plot':
        'A paraplegic marine dispatched to the moon Pandora on a unique mission becomes torn between following his orders and protecting the world he feels is his home.',
    'Poster':
        'http://ia.media-imdb.com/images/M/MV5BMTYwOTEwNjAzMl5BMl5BanBnXkFtZTcwODc5MTUwMw@@._V1_SX300.jpg',
    'Metascore': '83',
    'imdbRating': '7.9',
    'Images': <String>[
      'https://images-na.ssl-images-amazon.com/images/M/MV5BMjEyOTYyMzUxNl5BMl5BanBnXkFtZTcwNTg0MTUzNA@@._V1_.jpg',
      'https://images-na.ssl-images-amazon.com/images/M/MV5BNzM2MDk3MTcyMV5BMl5BanBnXkFtZTcwNjg0MTUzNA@@._V1_.jpg',
    ],
  };

  group('Movie.fromJson', () {
    test('parses all fields from a typical movie_data.json entry', () {
      final movie = Movie.fromJson(avatarJson);

      expect(movie.title, 'Avatar');
      expect(movie.year, '2009');
      expect(movie.genre, 'Action, Adventure, Fantasy');
      expect(movie.director, 'James Cameron');
      expect(movie.actors,
          'Sam Worthington, Zoe Saldana, Sigourney Weaver, Stephen Lang');
      expect(movie.plot, contains('paraplegic marine'));
      expect(movie.metascore, '83');
      expect(movie.imdbRating, '7.9');
      expect(movie.images.length, 2);
      expect(movie.posterUrl, startsWith('https://'));
    });

    test('skips http poster (only https posters are prepended)', () {
      final movie = Movie.fromJson(avatarJson);
      expect(
        movie.images.any((url) => url.startsWith('http://')),
        isFalse,
        reason: 'http Poster from movie_data.json should not be inserted',
      );
    });

    test('prepends an https Poster that is not already in Images', () {
      final json = <String, dynamic>{
        'Title': 'Test',
        'Year': '2020',
        'Director': 'Dir',
        'Actors': 'A, B',
        'Plot': 'p',
        'Genre': 'Drama',
        'imdbRating': '8.0',
        'Metascore': '70',
        'Poster': 'https://example.com/poster.jpg',
        'Images': <String>['https://example.com/still.jpg'],
      };
      final movie = Movie.fromJson(json);
      expect(movie.images.first, 'https://example.com/poster.jpg');
      expect(movie.images.length, 2);
    });

    test('uses sensible defaults when fields are missing', () {
      final movie = Movie.fromJson(<String, dynamic>{});
      expect(movie.title, '');
      expect(movie.year, '');
      expect(movie.images, isEmpty);
      expect(movie.posterUrl, '');
    });
  });

  group('Movie.toJson', () {
    test('emits the same OMDb-style keys used by fromJson', () {
      final movie = Movie.fromJson(avatarJson);
      final out = movie.toJson();

      expect(out['Title'], 'Avatar');
      expect(out['Year'], '2009');
      expect(out['Director'], 'James Cameron');
      expect(out['Genre'], 'Action, Adventure, Fantasy');
      expect(out['imdbRating'], '7.9');
      expect(out['Metascore'], '83');
      expect(out['Images'], isA<List<String>>());
    });

    test('round-trips through fromJson without losing data', () {
      final original = Movie.fromJson(avatarJson);
      final restored = Movie.fromJson(original.toJson());

      expect(restored.title, original.title);
      expect(restored.year, original.year);
      expect(restored.director, original.director);
      expect(restored.actors, original.actors);
      expect(restored.plot, original.plot);
      expect(restored.genre, original.genre);
      expect(restored.imdbRating, original.imdbRating);
      expect(restored.metascore, original.metascore);
      expect(restored.images, original.images);
    });
  });
}
