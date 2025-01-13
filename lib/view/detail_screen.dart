import 'package:flutter/material.dart';

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
          ],
        ),
      ),
    );
  }
}
