import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/cubit/movies_cubit.dart';
import 'package:movies_app/view/detail_screen.dart';

class MoviesListScreen extends StatefulWidget {
  const MoviesListScreen({super.key});

  @override
  State<MoviesListScreen> createState() => _MoviesListScreenState();
}

class _MoviesListScreenState extends State<MoviesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<MoviesCubit>().fetchMovies();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !context.read<MoviesCubit>().isFetchingMore) {
      context.read<MoviesCubit>().fetchMoreMovies();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Movies',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) =>
                  context.read<MoviesCubit>().searchMovies(query),
            ),
          ),
          Expanded(
            child: BlocBuilder<MoviesCubit, MoviesState>(
              builder: (context, state) {
                if (state is MoviesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is MoviesFailed) {
                  return const Center(
                    child: Text(
                      'Failed to load movies. Please try again.',
                    ),
                  );
                } else if (state is MoviesLoaded) {
                  if (state.movies.isEmpty || state.filteredMovies.isEmpty) {
                    return Text('Sorry, No movies found!');
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.filteredMovies.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.filteredMovies.length) {
                        return state.hasMore
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      }
                      final movie = state.filteredMovies[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: movie['posterURL'] != null
                                ? Image.network(
                                    movie['posterURL'],
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.movie, size: 50),
                            title: Text(
                              movie['title'] ?? 'No Title',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              movie['releaseDate'] ?? 'No Release Date',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: Text(
                    'Failed to load movies. Please try again.',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
