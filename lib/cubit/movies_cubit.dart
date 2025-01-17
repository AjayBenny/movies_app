import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  MoviesCubit() : super(MoviesInitial());

  bool isFetchingMore = false;
  int currentPage = 1;
  bool hasMore = true;

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
          hasMore: false,
        ));
      }
    } catch (e) {
      emit(MoviesFailed());
    }
  }

  Future<void> fetchMoreMovies() async {
    if (!hasMore || isFetchingMore) return;
    isFetchingMore = true;
    currentPage++;
    try {
      const String url = 'https://api.sampleapis.com/movies/animation';
      final response = await http.get(Uri.parse(url));
      final additionalMovies = jsonDecode(response.body);
      if (additionalMovies.isEmpty) hasMore = false;
      final currentState = state as MoviesLoaded;
      emit(MoviesLoaded(
        movies: currentState.movies + additionalMovies,
        filteredMovies: currentState.filteredMovies + additionalMovies,
        hasMore: hasMore,
      ));
    } catch (e) {
      isFetchingMore = false;
    } finally {
      isFetchingMore = false;
    }
  }

  void searchMovies(String query) {
    final currentState = state;
    if (currentState is MoviesLoaded) {
      if (query.isEmpty) {
        emit(
          MoviesLoaded(
            movies: currentState.movies,
            filteredMovies: currentState.movies,
            hasMore: false,
          ),
        );
      } else {
        final filtered = currentState.movies.where((movie) {
          final title = movie['title']?.toLowerCase() ?? '';
          return title.contains(query.toLowerCase());
        }).toList();
        emit(MoviesLoaded(
          movies: currentState.movies,
          filteredMovies: filtered,
          hasMore: false,
        ));
      }
    }
  }

  void saveFavourites() {}
}
