import 'package:flutter/material.dart';

class FavouritesScreen extends StatelessWidget {
  final List<dynamic> favourites;
  const FavouritesScreen({super.key, required this.favourites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite Movies'),
      ),
      body: favourites.isEmpty
          ? Center(child: Text('No favourites yet.'))
          : ListView.builder(
              itemCount: favourites.length,
              itemBuilder: (context, index) {
                final movie = favourites[index];
                return Card(
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
                );
              },
            ),
    );
  }
}
