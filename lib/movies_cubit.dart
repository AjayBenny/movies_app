import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  MoviesCubit() : super(MoviesInitial());

  Future<void> fetchMovies() async {
    emit(MoviesLoading());
    const String url = 'https://api.sampleapis.com/movies/animation';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> movies = jsonDecode(response.body);
        emit(MoviesLoaded(
          movies: movies,
          filteredMovies: movies,
        ));
      } else {
        await _loadOfflineFavourites();
      }
    } catch (e) {
      await _loadOfflineFavourites();
    }
  }

  Future<void> _loadOfflineFavourites() async {
    final favourites = await getOfflineFavourites();
    emit(MoviesFailed(offlineFavourites: favourites));
  }

  Future<List<dynamic>> getOfflineFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final favouriteKeys = prefs.getKeys();

    return favouriteKeys.where((key) => prefs.getBool(key) == true).map((key) {
      return {
        'id': key,
        'title': prefs.getString('$key-title') ?? 'No Title',
        'posterURL': prefs.getString('$key-posterURL'),
        'releaseDate': prefs.getString('$key-releaseDate'),
      };
    }).toList();
  }

  void searchMovies(String query) {
    final currentState = state;
    if (currentState is MoviesLoaded) {
      if (query.isEmpty) {
        emit(MoviesLoaded(
            movies: currentState.movies, filteredMovies: currentState.movies));
      } else {
        final filtered = currentState.movies.where((movie) {
          final title = movie['title']?.toLowerCase() ?? '';
          return title.contains(query.toLowerCase());
        }).toList();
        emit(MoviesLoaded(
            movies: currentState.movies, filteredMovies: filtered));
      }
    }
  }

  Future<List<dynamic>> getFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final favouriteKeys = prefs.getKeys();
    final currentState = state;

    if (currentState is MoviesLoaded) {
      return currentState.movies.where((movie) {
        return favouriteKeys.contains(movie['id'].toString()) &&
            prefs.getBool(movie['id'].toString()) == true;
      }).toList();
    } else {
      // Return only stored favourites when offline or other failure
      return favouriteKeys
          .where((key) => prefs.getBool(key) == true)
          .map((key) {
        return {
          'id': key,
          'title': prefs.getString('$key-title') ?? 'No Title',
          'posterURL': prefs.getString('$key-posterURL'),
          'releaseDate': prefs.getString('$key-releaseDate'),
        };
      }).toList();
    }
  }

  Future<void> saveFavouriteLocally(dynamic movie) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(movie['id'].toString(), true);
    prefs.setString('${movie['id']}-title', movie['title'] ?? '');
    prefs.setString('${movie['id']}-posterURL', movie['posterURL'] ?? '');
    prefs.setString('${movie['id']}-releaseDate', movie['releaseDate'] ?? '');
  }

  Future<void> removeFavouriteLocally(dynamic movie) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(movie['id'].toString());
    prefs.remove('${movie['id']}-title');
    prefs.remove('${movie['id']}-posterURL');
    prefs.remove('${movie['id']}-releaseDate');
  }
}
