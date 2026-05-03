class Movie {
  final String title;
  final String year;
  final String director;
  final String actors;
  final String plot;
  final String genre;
  final String imdbRating;
  final String metascore;
  final List<String> images;

  Movie({
    required this.title,
    required this.year,
    required this.director,
    required this.actors,
    required this.plot,
    required this.genre,
    required this.imdbRating,
    required this.metascore,
    required this.images,
  });

  String get posterUrl => images.isNotEmpty ? images.first : '';

  Map<String, dynamic> toJson() => {
        'Title': title,
        'Year': year,
        'Director': director,
        'Actors': actors,
        'Plot': plot,
        'Genre': genre,
        'imdbRating': imdbRating,
        'Metascore': metascore,
        'Images': images,
      };

  Map<String, dynamic> toMap() => {
        'title': title,
        'year': year,
        'director': director,
        'actors': actors,
        'plot': plot,
        'genre': genre,
        'imdbRating': imdbRating,
        'metascore': metascore,
        'images': images.join('|'),
      };

  factory Movie.fromMap(Map<String, dynamic> map) => Movie(
        title: map['title'] as String? ?? '',
        year: map['year'] as String? ?? '',
        director: map['director'] as String? ?? '',
        actors: map['actors'] as String? ?? '',
        plot: map['plot'] as String? ?? '',
        genre: map['genre'] as String? ?? '',
        imdbRating: map['imdbRating'] as String? ?? '',
        metascore: map['metascore'] as String? ?? '',
        images: (map['images'] as String? ?? '')
            .split('|')
            .where((s) => s.isNotEmpty)
            .toList(),
      );

  factory Movie.fromJson(Map<String, dynamic> json) {
    final rawImages = json['Images'] as List<dynamic>? ?? [];
    final poster = json['Poster'] as String? ?? '';
    final images = rawImages.map((e) => e as String).toList();
    if (poster.startsWith('https://') && !images.contains(poster)) {
      images.insert(0, poster);
    }
    return Movie(
      title: json['Title'] as String? ?? '',
      year: json['Year'] as String? ?? '',
      director: json['Director'] as String? ?? '',
      actors: json['Actors'] as String? ?? '',
      plot: json['Plot'] as String? ?? '',
      genre: json['Genre'] as String? ?? '',
      imdbRating: json['imdbRating'] as String? ?? '',
      metascore: json['Metascore'] as String? ?? '',
      images: images,
    );
  }
}
