import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'movie.dart';

class MovieDatabase {
  MovieDatabase._();
  static final MovieDatabase instance = MovieDatabase._();

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'movies.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE movies (
            title TEXT PRIMARY KEY,
            year TEXT,
            director TEXT,
            actors TEXT,
            plot TEXT,
            genre TEXT,
            imdbRating TEXT,
            metascore TEXT,
            images TEXT
          )
        ''');
      },
    );
  }

  Future<void> replaceAll(List<Movie> movies) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('movies');
    for (final movie in movies) {
      batch.insert(
        'movies',
        movie.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Movie>> search(String query) async {
    final db = await database;
    final rows = query.isEmpty
        ? await db.query('movies', orderBy: 'title COLLATE NOCASE')
        : await db.query(
            'movies',
            where: 'title LIKE ?',
            whereArgs: ['%$query%'],
            orderBy: 'title COLLATE NOCASE',
          );
    return rows.map(Movie.fromMap).toList();
  }

  Future<int> count() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM movies');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
