part of 'movies_cubit.dart';

@immutable
sealed class MoviesState {}

final class MoviesInitial extends MoviesState {}

final class MoviesLoading extends MoviesState {}

final class MoviesLoaded extends MoviesState {
  final List<dynamic> movies;
  final List<dynamic> filteredMovies;
  final bool hasMore;
  MoviesLoaded({
    required this.movies,
    required this.filteredMovies,
    required this.hasMore,
  });
}

final class MoviesFailed extends MoviesState {}
