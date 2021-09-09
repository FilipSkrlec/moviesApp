import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/assets/colors/colors.dart';
import 'package:movies_app/assets/texts/texts.dart';
import 'package:movies_app/models/MovieImageName.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'actor_search_screen.dart';
import 'movie_details_screen.dart';
import 'movie_search_screen.dart';

class HomePageScreen extends StatefulWidget {
  final String title;
  final String apiKey;

  HomePageScreen({Key? key, required this.title, required this.apiKey})
      : super(key: key);

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final movieSearchInputController = TextEditingController();
  final actorSearchInputController = TextEditingController();

  var jsonData;
  int _page = 1;
  List<MovieImageName> moviesList = [];

  String guestSessionId = "";
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    loadSavedData();
    getMoviesData();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0) {
          getMoviesData();
        }
      }
    });
  }

  void scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.linear);
  }

  Future getMoviesData() async {
    try {
      if (guestSessionId == "") {
        var response = await http
            .get(Uri.https(
                'api.themoviedb.org', '3/authentication/guest_session/new', {
              "api_key": widget.apiKey,
            }))
            .timeout(Duration(seconds: 5));
        jsonData = jsonDecode(response.body);
        guestSessionId = jsonData["guest_session_id"];
      }
      if (this._page <= 13) {
        var response = await http
            .get(Uri.https('api.themoviedb.org', '3/movie/top_rated', {
              "api_key": widget.apiKey,
              "language": "en-US",
              "page": this._page.toString(),
            }))
            .timeout(Duration(seconds: 5));
        jsonData = jsonDecode(response.body);

        if (this._page == 1) {
          if (jsonData["results"] != {}) {
            this.moviesList = [];
          }
          int counter = 1;
          SharedPreferences prefs = await SharedPreferences.getInstance();

          for (var movie in jsonData["results"]) {
            prefs.setString(
                movie["id"].toString(),
                movie["title"] +
                    "|###|" +
                    movie["backdrop_path"] +
                    "|###|" +
                    counter.toString());
            counter++;
          }
        }

        setState(() {
          for (var movie in jsonData["results"]) {
            MovieImageName newMovie = MovieImageName(
                movie["id"].toString(), movie["title"], movie["backdrop_path"]);
            this.moviesList.add(newMovie);
          }

          _page++;
          jsonData = null;
        });
      }
    } on TimeoutException catch (_) {
      _showNoConnectionDialog();
    } on SocketException catch (_) {
      _showNoConnectionDialog();
    } on Error catch (_) {
      _showNoConnectionDialog();
    }
  }

  Future<void> _showNoConnectionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(noConnectionDialogTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(noConnectionDialogMessage),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(noConnectionDialogButtonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future navigateToMovieDetailsScreen(BuildContext context, String id) async {
    try {
      var responseById = await http
          .get(Uri.https('api.themoviedb.org', '3/movie/$id',
              {"api_key": widget.apiKey, "language": "en-US"}))
          .timeout(Duration(seconds: 5));
      var jsonMovieData = jsonDecode(responseById.body);

      Map<String, String> movieDataMap = {};

      for (var detail in Map.from(jsonMovieData).keys) {
        if (detail == "genres") {
          List<String> movieGenres = [];
          for (var genre in jsonMovieData[detail]) {
            movieGenres.add(genre["name"]);
          }
          String finalString = "|";
          for (var genre in movieGenres) {
            finalString += genre;
            finalString += "|";
          }
          movieDataMap[detail] = finalString;
        } else if (detail == "production_companies") {
          List<String> productionCompanies = [];
          for (var company in jsonMovieData[detail]) {
            productionCompanies.add(company["name"]);
          }
          String finalString = "";
          for (var company in productionCompanies) {
            finalString += company;
            movieDataMap[detail] = finalString;
          }
          movieDataMap[detail] = finalString;
        } else {
          movieDataMap[detail] = jsonMovieData[detail].toString();
        }
      }

      var responseCredits = await http
          .get(Uri.https('api.themoviedb.org', '3/movie/$id/credits',
              {"api_key": widget.apiKey, "language": "en-US"}))
          .timeout(Duration(seconds: 5));

      var jsonCreditsData = jsonDecode(responseCredits.body)["cast"];

      Map<String, Map<String, String>> topActorsDetails = {};

      for (int i = 0; i < 5; i++) {
        Map<String, String> actorDetails = {};
        actorDetails["name"] = jsonCreditsData[i]["name"];
        actorDetails["profile_path"] = jsonCreditsData[i]["profile_path"];
        actorDetails["character"] = jsonCreditsData[i]["character"];
        topActorsDetails[jsonCreditsData[i]["id"].toString()] = actorDetails;
      }

      var responseMovieReviews = await http
          .get(Uri.https(
            'api.themoviedb.org',
            '3/movie/$id/reviews',
            {"api_key": widget.apiKey, "language": "en-US"},
          ))
          .timeout(Duration(seconds: 5));

      var jsonMovieReviews = jsonDecode(responseMovieReviews.body)["results"];

      Map<String, Map<String, String>> reviews = {};

      for (var review in jsonMovieReviews) {
        Map<String, String> reviewData = {};
        reviewData["author"] = review["author"];
        reviewData["reviewer_rating"] =
            review["author_details"]["rating"].toString();
        reviewData["review_text"] = review["content"];
        reviews[review["id"]] = reviewData;
      }

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MovieDetailsScreen(
                title: appTitle,
                movieDetails: movieDataMap,
                topActorsDetails: topActorsDetails,
                reviews: reviews,
                guestSessionId: this.guestSessionId,
                apiKey: widget.apiKey,
              )));
    } on TimeoutException catch (_) {
      _showNoConnectionDialog();
    } on SocketException catch (_) {
      _showNoConnectionDialog();
    } on Error catch (_) {
      _showNoConnectionDialog();
    }
  }

  Future navigateToMovieSearchScreen(BuildContext context, String query) async {
    try {
      var responseByMovieQuery = await http
          .get(Uri.https('api.themoviedb.org', '3/search/movie', {
            "api_key": widget.apiKey,
            "language": "en-US",
            "query": query,
            "page": "1"
          }))
          .timeout(Duration(seconds: 5));
      var jsonMovieSearchData =
          jsonDecode(responseByMovieQuery.body)["results"];

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MovieSearchScreen(
                title: appTitle,
                movieSearchData: jsonMovieSearchData,
                query: query,
                guestSessionId: this.guestSessionId,
                apiKey: widget.apiKey,
              )));
    } on TimeoutException catch (_) {
      _showNoConnectionDialog();
    } on SocketException catch (_) {
      _showNoConnectionDialog();
    } on Error catch (_) {
      _showNoConnectionDialog();
    }
  }

  Future navigateToActorSearchScreen(BuildContext context, String query) async {
    try {
      var responseByActorQuery = await http
          .get(Uri.https('api.themoviedb.org', '3/search/person', {
            "api_key": widget.apiKey,
            "language": "en-US",
            "query": query,
            "page": "1"
          }))
          .timeout(Duration(seconds: 5));
      var jsonActorSearchData =
          jsonDecode(responseByActorQuery.body)["results"];

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ActorSearchScreen(
                title: appTitle,
                actorSearchData: jsonActorSearchData,
                query: query,
                apiKey: widget.apiKey,
              )));
    } on TimeoutException catch (_) {
      _showNoConnectionDialog();
    } on SocketException catch (_) {
      _showNoConnectionDialog();
    } on Error catch (_) {
      _showNoConnectionDialog();
    }
  }

  void loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final movieKeys = prefs.getKeys();

    for (int i = 0; i < movieKeys.length; i++) {
      moviesList.add(MovieImageName("", "", ""));
    }

    setState(() {
      for (String key in movieKeys) {
        moviesList[int.parse(prefs.get(key).toString().split("|###|")[2]) - 1] =
            MovieImageName(key, prefs.get(key).toString().split("|###|")[0],
                prefs.get(key).toString().split("|###|")[1]);
      }
    });

    if (this._page == 1) {
      await prefs.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: blackBackground,
      body: Center(
          child: ListView(
        controller: _scrollController,
        children: <Widget>[
          TextField(
              controller: this.movieSearchInputController,
              style: TextStyle(color: yellowDetail),
              decoration: InputDecoration(
                labelStyle: TextStyle(color: yellowDetail),
                labelText: searchMovieBarText,
                suffixIcon: IconButton(
                    icon: Icon(Icons.search_rounded),
                    onPressed: () => navigateToMovieSearchScreen(
                        context, this.movieSearchInputController.text)),
              )),
          TextField(
              controller: this.actorSearchInputController,
              style: TextStyle(color: yellowDetail),
              decoration: InputDecoration(
                labelStyle: TextStyle(color: yellowDetail),
                labelText: searchActorBarText,
                suffixIcon: IconButton(
                    icon: Icon(Icons.search_sharp),
                    onPressed: () => navigateToActorSearchScreen(
                        context, this.actorSearchInputController.text)),
              )),
          ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: this.moviesList.length,
              itemBuilder: (context, index) {
                return Center(
                    child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      decoration: BoxDecoration(
                          border: Border.all(width: 3, color: yellowDetail),
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0))),
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: TextButton(
                          onPressed: () => navigateToMovieDetailsScreen(
                              context, this.moviesList[index].getId()),
                          child: Text(this.moviesList[index].getName(),
                              style: TextStyle(
                                  fontSize: 21, color: yellowDetail))),
                    ),
                    CachedNetworkImage(
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      imageUrl: "https://image.tmdb.org/t/p/w500" +
                          this.moviesList[index].getBackdropPath(),
                    ),
                  ],
                ));
              })
        ],
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellowDetail,
        onPressed: scrollToTop,
        tooltip: scrollTopTooltip,
        child: Icon(Icons.arrow_upward_sharp),
      ),
    );
  }
}
