import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_list/network/data.dart';
import 'package:flutter_list/widgets/movie_list.dart';

class MoviesListPage extends StatelessWidget {
  final Future<List<Movie>> movies;
  final String title;

  MoviesListPage({this.title, this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: FutureBuilder(
            future: movies,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
              
                return VerticalMovieList(snapshot.data);
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}