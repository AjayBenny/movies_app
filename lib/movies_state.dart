part of 'movies_cubit.dart';

@immutable
sealed class MoviesState {}

final class MoviesInitial extends MoviesState {}

final class MoviesLoading extends MoviesState {}

final class MoviesLoaded extends MoviesState {
  final List<dynamic> movies;
  final List<dynamic> filteredMovies;
  MoviesLoaded({
    required this.movies,
    required this.filteredMovies,
  });
}

final class MoviesFailed extends MoviesState {
  final bool hasNetworkError;
  final List<dynamic> offlineFavourites;
  MoviesFailed(
      {this.hasNetworkError = false, this.offlineFavourites = const []});
}
