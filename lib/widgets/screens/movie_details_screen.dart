import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/assets/colors/colors.dart';
import 'package:movies_app/assets/texts/texts.dart';
import 'package:movies_app/widgets/category_data.dart';
import 'package:movies_app/widgets/category_name.dart';
import 'actor_detail_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String title;
  final Map<String, String> movieDetails;
  final Map<String, String> topActors;
  final Map<String, Map<String, String>> reviews;
  final String guestSessionId;
  final String apiKey;

  const MovieDetailsScreen(
      {Key? key,
      required this.title,
      required this.movieDetails,
      required this.topActors,
      required this.reviews,
      required this.guestSessionId,
      required this.apiKey})
      : super(key: key);

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  String selectedRating = "1.0";
  bool isRated = false;

  Future navigateToActorDetailScreen(BuildContext context, String id) async {
    var responseById = await http.get(Uri.https('api.themoviedb.org',
        '3/person/$id', {"api_key": widget.apiKey, "language": "en-US"}));
    var jsonActorData = jsonDecode(responseById.body);

    Map<String, String> actorDataMap = {};

    for (var detail in Map.from(jsonActorData).keys) {
      actorDataMap[detail] = jsonActorData[detail].toString();
    }

    var responseTopMovies = await http.get(Uri.https(
        'api.themoviedb.org',
        '3/person/$id/movie_credits',
        {"api_key": widget.apiKey, "language": "en-US"}));

    var jsonTopMoviesData = jsonDecode(responseTopMovies.body)["cast"];

    String topMovies = "";

    for (int i = 0; i < 5; i++) {
      topMovies += jsonTopMoviesData[i]["title"];
      topMovies += "\n";
    }

    actorDataMap["top_movies"] = topMovies;

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ActorDetailScreen(
              title: appTitle,
              actorDetails: actorDataMap,
              apiKey: widget.apiKey,
            )));
  }

  Future rateMovie(BuildContext context, String id) async {
    if (this.selectedRating != "") {
      var responseByRateRequest = await http.post(
        Uri.https('api.themoviedb.org', '3/movie/$id/rating', {
          "api_key": widget.apiKey,
          "guest_session_id": widget.guestSessionId
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, double>{
          'value': double.parse(this.selectedRating),
        }),
      );
      var jsonResponseByRate = jsonDecode(responseByRateRequest.body);

      setState(() {
        if (jsonResponseByRate["success"] == true) {
          this.isRated = true;
        }
      });
    }
  }

  Future deleteMovieRating(BuildContext context, String id) async {
    var responseByDeleteRateRequest = await http.delete(
      Uri.https('api.themoviedb.org', '3/movie/$id/rating', {
        "api_key": widget.apiKey,
        "guest_session_id": widget.guestSessionId
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var jsonResponseByDelete = jsonDecode(responseByDeleteRateRequest.body);

    setState(() {
      if (jsonResponseByDelete["success"] == true) {
        this.isRated = false;
      }
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
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: yellowDetail),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          bottomRight: Radius.circular(25.0))),
                  child: Text(
                    widget.movieDetails["title"] ?? "",
                    style: TextStyle(color: yellowDetail, fontSize: 30),
                  )),
              CategoryNameWidget(categoryName: categoryMovieLabels["rating"]!),
              this.isRated
                  ? Container(
                      child: Text(
                        ratedMovieText + this.selectedRating,
                        style:
                            TextStyle(color: ratedMessageGreen, fontSize: 18),
                      ),
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    )
                  : DropdownButton<String>(
                      hint: Text(
                        ratingDropdownButtonText,
                        style: TextStyle(
                          color: yellowDetail,
                        ),
                      ),
                      value: this.selectedRating,
                      dropdownColor: blackBackground,
                      style: TextStyle(color: yellowDetail, fontSize: 20),
                      items: possibleMovieRatings.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: new Text(
                            value,
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        this.setState(() {
                          this.selectedRating = newValue!;
                        });
                      },
                    ),
              this.isRated
                  ? TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(deleteRatingRed)),
                      onPressed: () => deleteMovieRating(
                          context, widget.movieDetails["id"].toString()),
                      child: Text(deleteMovieButtonText,
                          style: TextStyle(
                            color: blackBackground,
                            fontSize: 20,
                          )))
                  : TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(yellowDetail)),
                      onPressed: () => rateMovie(
                          context, widget.movieDetails["id"].toString()),
                      child: Text(rateMovieButtonText,
                          style: TextStyle(
                            color: blackBackground,
                            fontSize: 20,
                          ))),
              CategoryNameWidget(categoryName: categoryMovieLabels["genres"]!),
              CategoryDataWidget(
                  categoryData:
                      widget.movieDetails["genres"] ?? unknownDataText),
              CategoryNameWidget(
                  categoryName: categoryMovieLabels["release_date"]!),
              CategoryDataWidget(
                  categoryData:
                      widget.movieDetails["release_date"] ?? unknownDataText),
              CategoryNameWidget(
                  categoryName: categoryMovieLabels["production_companies"]!),
              CategoryDataWidget(
                  categoryData: widget.movieDetails["production_companies"] ??
                      unknownDataText),
              CategoryNameWidget(categoryName: categoryMovieLabels["runtime"]!),
              CategoryDataWidget(
                  categoryData: widget.movieDetails["runtime"]! + " minutes"),
              CategoryNameWidget(
                  categoryName: categoryMovieLabels["vote_average"]!),
              CategoryDataWidget(
                  categoryData:
                      widget.movieDetails["vote_average"] ?? noDataText),
              CategoryNameWidget(
                  categoryName: categoryMovieLabels["vote_count"]!),
              CategoryDataWidget(
                  categoryData:
                      widget.movieDetails["vote_count"] ?? noDataText),
              CategoryNameWidget(
                  categoryName: categoryMovieLabels["overview"]!),
              CategoryDataWidget(
                  categoryData: widget.movieDetails["overview"] ?? noDataText),
              CategoryNameWidget(
                  categoryName: categoryMovieLabels["main_actors"]!),
              Column(
                  children: widget.topActors.keys
                      .map((item) => new Container(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: TextButton(
                            onPressed: () =>
                                navigateToActorDetailScreen(context, item),
                            child: Text(
                              widget.topActors[item] ?? noDataText,
                              style: TextStyle(color: linkBlue, fontSize: 20),
                            ),
                          )))
                      .toList()),
              CategoryNameWidget(categoryName: categoryMovieLabels["reviews"]!),
              Column(
                  children: widget.reviews.values
                      .map((item) => new Container(
                          decoration: BoxDecoration(
                            color: yellowDetail,
                            border:
                                Border.all(width: 3, color: blackBackground),
                          ),
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Column(children: [
                            Row(children: [
                              Text(
                                item["author"]! + "  |  ",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                item["reviewer_rating"] ?? noDataText,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.star_border_outlined)
                            ]),
                            Text(
                              item["review_text"] ?? noDataText,
                              style: TextStyle(
                                  color: blackBackground, fontSize: 16),
                            ),
                          ])))
                      .toList()),
            ],
          )
        ],
      )),
    );
  }
}
