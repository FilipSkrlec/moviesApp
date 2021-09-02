import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  Map<String, String> movieTitlesIds = {};
  int _page = 1;

  String guestSessionId = "";

  Future getMoviesData() async {
    if (guestSessionId == "") {
      var response = await http.get(Uri.https(
          'api.themoviedb.org', '3/authentication/guest_session/new', {
        "api_key": widget.apiKey,
      }));
      jsonData = jsonDecode(response.body);
      guestSessionId = jsonData["guest_session_id"];
    }
    if (this._page <= 13) {
      var response =
          await http.get(Uri.https('api.themoviedb.org', '3/movie/top_rated', {
        "api_key": widget.apiKey,
        "language": "en-US",
        "page": this._page.toString(),
      }));
      jsonData = jsonDecode(response.body);

      if (this._page == 1) {
        this.movieTitlesIds = {};
        SharedPreferences prefs = await SharedPreferences.getInstance();

        for (var movie in jsonData["results"]) {
          prefs.setString(movie["id"].toString(), movie["title"]);
        }
      }

      setState(() {
        for (var movie in jsonData["results"]) {
          this.movieTitlesIds[movie["id"].toString()] = movie["title"];
        }

        _page++;
        jsonData = null;
      });
    }
  }

  Future navigateToMovieDetailsScreen(BuildContext context, String id) async {
    var responseById = await http.get(Uri.https('api.themoviedb.org',
        '3/movie/$id', {"api_key": widget.apiKey, "language": "en-US"}));
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

    var responseCredits = await http.get(Uri.https(
        'api.themoviedb.org',
        '3/movie/$id/credits',
        {"api_key": widget.apiKey, "language": "en-US"}));

    var jsonCreditsData = jsonDecode(responseCredits.body)["cast"];
    Map<String, String> topActorsIds = {};

    for (int i = 0; i < 5; i++) {
      topActorsIds[jsonCreditsData[i]["id"].toString()] =
          jsonCreditsData[i]["name"];
    }

    var responseMovieReviews = await http.get(Uri.https(
      'api.themoviedb.org',
      '3/movie/$id/reviews',
      {"api_key": widget.apiKey, "language": "en-US"},
    ));

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
              movieDetails: movieDataMap,
              topActors: topActorsIds,
              reviews: reviews,
              guestSessionId: this.guestSessionId,
              apiKey: widget.apiKey,
            )));
  }

  Future navigateToMovieSearchScreen(BuildContext context, String query) async {
    var responseByMovieQuery = await http.get(Uri.https(
        'api.themoviedb.org', '3/search/movie', {
      "api_key": widget.apiKey,
      "language": "en-US",
      "query": query,
      "page": "1"
    }));
    var jsonMovieSearchData = jsonDecode(responseByMovieQuery.body)["results"];

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MovieSearchScreen(
              movieSearchData: jsonMovieSearchData,
              query: query,
              guestSessionId: this.guestSessionId,
              apiKey: widget.apiKey,
            )));
  }

  Future navigateToActorSearchScreen(BuildContext context, String query) async {
    var responseByActorQuery = await http.get(Uri.https(
        'api.themoviedb.org', '3/search/person', {
      "api_key": widget.apiKey,
      "language": "en-US",
      "query": query,
      "page": "1"
    }));
    var jsonActorSearchData = jsonDecode(responseByActorQuery.body)["results"];

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ActorSearchScreen(
              actorSearchData: jsonActorSearchData,
              query: query,
              apiKey: widget.apiKey,
            )));
  }

  void loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final movieKeys = prefs.getKeys();

    setState(() {
      for (String key in movieKeys) {
        this.movieTitlesIds[key] = prefs.get(key).toString();
      }
    });

    if (this._page == 1) {
      await prefs.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_page == 1) loadSavedData();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Color(0xFF101820),
      body: Center(
          child: ListView(
        children: <Widget>[
          TextField(
              controller: this.movieSearchInputController,
              style: TextStyle(color: Color(0xFFFEE715)),
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Color(0xFFFEE715)),
                labelText: "Find movie:",
                suffixIcon: IconButton(
                    icon: Icon(Icons.search_rounded),
                    onPressed: () => navigateToMovieSearchScreen(
                        context, this.movieSearchInputController.text)),
              )),
          TextField(
              controller: this.actorSearchInputController,
              style: TextStyle(color: Color(0xFFFEE715)),
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Color(0xFFFEE715)),
                labelText: "Find actor:",
                suffixIcon: IconButton(
                    icon: Icon(Icons.search_sharp),
                    onPressed: () => navigateToActorSearchScreen(
                        context, this.actorSearchInputController.text)),
              )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              this.movieTitlesIds != {}
                  ? Column(
                      children: this
                          .movieTitlesIds
                          .keys
                          .map((item) => new Container(
                                margin:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 3, color: Color(0xFFFEE715)),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25.0),
                                        bottomRight: Radius.circular(25.0))),
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                                child: TextButton(
                                    onPressed: () =>
                                        navigateToMovieDetailsScreen(
                                            context, item),
                                    child: Text(
                                        this.movieTitlesIds[item] ?? "X",
                                        style: TextStyle(
                                            fontSize: 21,
                                            color: Color(0xFFFEE715)))),
                              ))
                          .toList())
                  : Text("Nema podataka")
            ],
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFEE715),
        onPressed: getMoviesData,
        tooltip: 'Get more movies',
        child: Icon(Icons.add),
      ),
    );
  }
}
