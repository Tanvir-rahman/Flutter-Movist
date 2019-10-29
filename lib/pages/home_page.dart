import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_list/network/api.dart';
import 'package:flutter_list/network/data.dart';
import 'package:flutter_list/pages/movies_list_page.dart';
import 'package:flutter_list/state/states.dart';
import 'package:flutter_list/widgets/movie_list.dart';
import 'package:flutter_list/widgets/side_menu.dart';
import 'package:provider/provider.dart';
import 'movie_detail_page.dart';
import 'movie_search_page.dart';

var cardAspectRatio = 12.0 / 16.0;
var widgetAspectRatio = cardAspectRatio * 1.2;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      drawer: SideMenu(),
      appBar: AppBar(
        title: Text('Movie DB'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: () {
              return showSearch(context: context, delegate: MovieSearchPage());
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('현재 상영작', style: themeData.textTheme.headline),
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoviesListPage(
                              title: '현재 상영작',
                              movies: MovieDBApi.getPlayNow(),
                            ),
                          ));
                    },
                  )
                ],
              ),
            ),
            FutureBuilder(
              future: MovieDBApi.getPlayNow(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return MovieCoverFlow(snapshot.data);
                } else {
                  return Container(
                      height: 460,
                      child: Center(child: CircularProgressIndicator()));
                }
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('나의 즐겨찾기', style: themeData.textTheme.headline),
                  Consumer<FavoriteState>(builder: (context, state, child) {
                    return IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MoviesListPage(
                                  title: 'My List',
                                  movies: MovieDBApi.getDetailMovies(
                                      state.movieIDs),
                                ),
                              ));
                        });
                  }),
                ],
              ),
            ),
            Consumer<FavoriteState>(builder: (context, state, child) {
              if (state.isEmpty()) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: Text('즐겨 찾기에 등록된 영화가 없습니다.',
                        style: themeData.textTheme.body1),
                  ),
                );
              }

              List<int> movieIDs = [];

              state.movieIDs.forEach((id) => movieIDs.add(id));

              return FutureBuilder(
                future: MovieDBApi.getDetailMovies(movieIDs),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return HorizontalMovieList(snapshot.data);
                  } else {
                    return Padding(
                        padding: EdgeInsets.all(100),
                        child: CircularProgressIndicator());
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class CardControllWidget extends StatelessWidget {
  var currentPage;
  var padding = 20.0;
  var verticalInset = 20.0;
  final List<Movie> movieDataList;

  CardControllWidget(this.currentPage, this.movieDataList);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          var width = constraints.maxWidth;
          var height = constraints.maxHeight;

          var safeWidth = width - 2 * padding;
          var safeHeight = height - 2 * padding;

          var heightOfPrimaryCard = safeHeight;
          var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

          var primaryCardLeft = safeWidth - widthOfPrimaryCard;
          var horizontalInset = primaryCardLeft / 2;

          List<Widget> cardList = List();

          for (var i = 0; i < movieDataList.length; i++) {
            var delta = i - currentPage;
            bool isOnRight = delta > 0;

            var start = padding +
                max(
                    primaryCardLeft -
                        horizontalInset * -delta * (isOnRight ? 15 : 1),
                    0.0);

            var cardItem = Positioned.directional(
              top: padding + verticalInset * max(-delta, 0.0),
              bottom: padding + verticalInset * max(-delta, 0.0),
              start: start,
              textDirection: TextDirection.rtl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        offset: Offset(3.9, 6.0),
                        blurRadius: 10.0)
                  ]),
                  child: AspectRatio(
                    aspectRatio: cardAspectRatio,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        FadeInImage(
                            image: NetworkImage(movieDataList[i].posterUrl),
                            fit: BoxFit.cover,
                            placeholder: AssetImage('assets/images/loading.gif'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            cardList.add(cardItem);
          }
          return Stack(
            children: cardList,
          );
        },
      ),
    );
  }
}

class MovieCoverFlow extends StatefulWidget {
  final List<Movie> movies;

  MovieCoverFlow(this.movies);

  @override
  State<StatefulWidget> createState() {
    return MovieCoverFlowState(movies: movies);
  }
}

class MovieCoverFlowState extends State<MovieCoverFlow> {
  final List<Movie> movies;

  double currentPage;

  MovieCoverFlowState({this.movies}) {
    currentPage = movies.length - 1.0;
  }

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: movies.length - 1);

    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MovieDetailsPage(movies[currentPage.toInt()]),
            ));
      },
      child: Stack(
        children: <Widget>[
          CardControllWidget(currentPage, movies),
          Positioned.fill(
            child: PageView.builder(
              itemCount: movies.length,
              controller: controller,
              reverse: true,
              itemBuilder: (context, index) {
                return Container();
              },
            ),
          )
        ],
      ),
    );
  }
}