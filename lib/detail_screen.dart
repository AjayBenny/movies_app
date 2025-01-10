import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'movies_cubit.dart';

class MovieDetailsScreen extends StatefulWidget {
  final dynamic movie;
  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  MovieDetailsScreenState createState() => MovieDetailsScreenState();
}

class MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    _loadFavouriteStatus();
  }

  Future<void> _loadFavouriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavourite = prefs.getBool(widget.movie['id'].toString()) ?? false;
    });
  }

  Future<void> _toggleFavourite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavourite = !isFavourite;
    });
    prefs.setBool(widget.movie['id'].toString(), isFavourite);
    if (isFavourite) {
      await context.read<MoviesCubit>().saveFavouriteLocally(widget.movie);
    } else {
      await context.read<MoviesCubit>().removeFavouriteLocally(widget.movie);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie['title'] ?? 'Movie Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.movie['posterURL'] != null
                ? Center(
                    child: Image.network(
                      widget.movie['posterURL'],
                      height: 200,
                    ),
                  )
                : Center(child: Icon(Icons.movie, size: 200)),
            SizedBox(height: 16),
            Text(
              'Title: ${widget.movie['title'] ?? 'No Title'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'IMDb ID: ${widget.movie['imdbID'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Mark as Favourite:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: isFavourite ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleFavourite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
