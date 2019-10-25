import 'package:flutter/material.dart';
import 'package:flutter_list/network/data.dart';
import 'package:flutter_list/pages/movie_detail_page.dart';

class HorizontalMovieList extends StatelessWidget {
  final List<Movie> movies;

  HorizontalMovieList(this.movies);

  @override
  Widget build(BuildContext context) {
    double _imageHeight = 150;

    return Container(
      height: 250,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              print(index);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MovieDetailsPage(movies[index])));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  width: _imageHeight * 0.7,
                  height: _imageHeight,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black54,
                            offset: Offset(0, 4),
                            blurRadius: 6)
                      ]),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        movies[index].posterUrl,
                        fit: BoxFit.cover,
                      )),
                ),
                Text(
                    movies[index].title.length <= 4
                        ? movies[index].title
                        : movies[index].title.substring(0, 3) + "...",
                    style: Theme.of(context).textTheme.body1)
              ],
            ),
          );
        },
      ),
    );
  }
}

class VerticalMovieList extends StatelessWidget {
  final List<Movie> movies;

  VerticalMovieList(this.movies);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: movies.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MovieDetailsPage(movies[index])));
              },
              child: Container(
                height: 150,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              width: 2,
                            color: Theme.of(context).accentColor,
                            )),
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 118.0, top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                movies[index].title,
                                style: Theme.of(context).textTheme.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      '${movies[index].vote_average}',
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 8,
                      child: SizedBox(
                        width: 100,
                        height: 125,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: FadeInImage(
                            image: NetworkImage(movies[index].posterUrl),
                            fit: BoxFit.cover,
                            placeholder:
                                AssetImage('assets/images/loading.gif'),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
