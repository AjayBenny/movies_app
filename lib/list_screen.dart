import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/detail_screen.dart';
import 'package:movies_app/movies_cubit.dart';

import 'favourites_screen.dart';

class MoviesListScreen extends StatelessWidget {
  const MoviesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () async {
              final favourites =
                  await context.read<MoviesCubit>().getFavourites();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FavouritesScreen(favourites: favourites),
                ),
              );
            },
          ),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
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
                  return Center(child: CircularProgressIndicator());
                } else if (state is MoviesFailed) {
                  return state.offlineFavourites.isEmpty
                      ? Center(child: Text('No favourites available offline.'))
                      : FavouritesScreen(favourites: state.offlineFavourites);
                  print('failed');
                  // if (state.hasNetworkError) {
                  //   return Center(
                  //     child: ElevatedButton(
                  //       onPressed: () async {
                  //         final favourites =
                  //             await context.read<MoviesCubit>().getFavourites();
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) =>
                  //                 FavouritesScreen(favourites: favourites),
                  //           ),
                  //         );
                  //       },
                  //       child: Text('Show Favourites (Offline)'),
                  //     ),
                  //   );
                  // }
                  return Center(
                      child: Text('Failed to load movies. Please try again.'));
                } else if (state is MoviesLoaded) {
                  return ListView.builder(
                    itemCount: state.filteredMovies.length,
                    itemBuilder: (context, index) {
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
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: movie['posterURL'] != null
                                ? Image.network(
                                    movie['posterURL'],
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.movie, size: 50),
                            title: Text(
                              movie['title'] ?? 'No Title',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              movie['releaseDate'] ?? 'No Release Date',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(
                    child: Text('Failed to load movies. Please try again.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
