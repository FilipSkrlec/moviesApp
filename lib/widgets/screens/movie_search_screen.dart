import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/assets/colors/colors.dart';
import 'movie_details_screen.dart';

class MovieSearchScreen extends StatefulWidget {
  final String title;
  final List<dynamic> movieSearchData;
  final String query;
  final String guestSessionId;
  final String apiKey;

  const MovieSearchScreen(
      {Key? key,
      required this.title,
      required this.movieSearchData,
      required this.query,
      required this.guestSessionId,
      required this.apiKey})
      : super(key: key);

  @override
  _MovieSearchScreenState createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  int _page = 2;

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
              title: 'Flutter Movie App',
              movieDetails: movieDataMap,
              topActors: topActorsIds,
              reviews: reviews,
              guestSessionId: widget.guestSessionId,
              apiKey: widget.apiKey,
            )));
  }

  Future getNextMoviePage() async {
    var responseByMovieQuery =
        await http.get(Uri.https('api.themoviedb.org', '3/search/movie', {
      "api_key": widget.apiKey,
      "language": "en-US",
      "query": widget.query,
      "page": this._page.toString(),
    }));
    var jsonMovieSearchData = jsonDecode(responseByMovieQuery.body)["results"];

    setState(() {
      for (var movie in jsonMovieSearchData) {
        widget.movieSearchData.add(movie);
      }
      _page++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      backgroundColor: blackBackground,
      body: Center(
          child: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                  children: widget.movieSearchData
                      .map((item) => new Container(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: TextButton(
                                onPressed: () => navigateToMovieDetailsScreen(
                                    context, item["id"].toString()),
                                child: Text(
                                  item["title"] ?? "",
                                  style: TextStyle(fontSize: 20),
                                )),
                          ))
                      .toList())
            ],
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellowDetail,
        onPressed: getNextMoviePage,
        tooltip: 'Get more movies',
        child: Icon(Icons.add),
      ),
    );
  }
}
