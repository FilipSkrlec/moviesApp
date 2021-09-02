import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/widgets/category_data.dart';
import 'package:movies_app/widgets/category_name.dart';
import 'actor_detail_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Map<String, String> movieDetails;
  final Map<String, String> topActors;
  final Map<String, Map<String, String>> reviews;
  final String guestSessionId;
  final String apiKey;

  const MovieDetailsScreen(
      {Key? key,
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
      backgroundColor: Color(0xFF101820),
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
                      border: Border.all(width: 3, color: Color(0xFFFEE715)),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          bottomRight: Radius.circular(25.0))),
                  child: Text(
                    widget.movieDetails["title"] ?? "",
                    style: TextStyle(color: Color(0xFFFEE715), fontSize: 30),
                  )),
              CategoryNameWidget(categoryName: "RATE THIS MOVIE:"),
              this.isRated
                  ? Container(
                      child: Text(
                        "YOU RATED MOVIE WITH " + this.selectedRating,
                        style: TextStyle(color: Colors.green, fontSize: 18),
                      ),
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    )
                  : DropdownButton<String>(
                      hint: Text(
                        "Rating:",
                        style: TextStyle(
                          color: Color(0xFFFEE715),
                        ),
                      ),
                      value: this.selectedRating,
                      dropdownColor: Color(0xFF101820),
                      style: TextStyle(color: Color(0xFFFEE715), fontSize: 20),
                      items: <String>[
                        '0.5',
                        '1.0',
                        '1.5',
                        '2.0',
                        '2.5',
                        '3.0',
                        '3.5',
                        '4.0',
                        '4.5',
                        '5.0',
                        '5.5',
                        '6.0',
                        '6.5',
                        '7.0',
                        '7.5',
                        '8.0',
                        '8.5',
                        '9.0',
                        '9.5',
                        '10.0'
                      ].map((String value) {
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
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () => deleteMovieRating(
                          context, widget.movieDetails["id"].toString()),
                      child: Text("DELETE",
                          style: TextStyle(
                            color: Color(0xFF101820),
                            fontSize: 20,
                          )))
                  : TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xFFFEE715))),
                      onPressed: () => rateMovie(
                          context, widget.movieDetails["id"].toString()),
                      child: Text("RATE",
                          style: TextStyle(
                            color: Color(0xFF101820),
                            fontSize: 20,
                          ))),
              CategoryNameWidget(categoryName: "GENRES:"),
              CategoryDataWidget(
                  categoryData: widget.movieDetails["genres"] ?? "unknown"),
              CategoryNameWidget(categoryName: "RELEASE DATE:"),
              CategoryDataWidget(
                  categoryData:
                      widget.movieDetails["release_date"] ?? "unknown"),
              CategoryNameWidget(categoryName: "PRODUCTION COMPANIES:"),
              CategoryDataWidget(
                  categoryData:
                      widget.movieDetails["production_companies"] ?? "unknown"),
              CategoryNameWidget(categoryName: "RUNTIME:"),
              CategoryDataWidget(
                  categoryData: widget.movieDetails["runtime"]! + " minutes"),
              CategoryNameWidget(categoryName: "VOTE AVERAGE:"),
              CategoryDataWidget(
                  categoryData: widget.movieDetails["vote_average"] ?? "-"),
              CategoryNameWidget(categoryName: "VOTE COUNT:"),
              CategoryDataWidget(
                  categoryData: widget.movieDetails["vote_count"] ?? "-"),
              CategoryNameWidget(categoryName: "OVERVIEW:"),
              CategoryDataWidget(
                  categoryData: widget.movieDetails["overview"] ?? "-"),
              CategoryNameWidget(categoryName: "MAIN ACTORS:"),
              Column(
                  children: widget.topActors.keys
                      .map((item) => new Container(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: TextButton(
                            onPressed: () =>
                                navigateToActorDetailScreen(context, item),
                            child: Text(
                              widget.topActors[item] ?? "X",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 20),
                            ),
                          )))
                      .toList()),
              CategoryNameWidget(categoryName: "REVIEWS:"),
              Column(
                  children: widget.reviews.values
                      .map((item) => new Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            border: Border.all(width: 3, color: Colors.black),
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
                                item["reviewer_rating"] ?? "0.0",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.star_border_outlined)
                            ]),
                            Text(
                              item["review_text"] ?? "",
                              style: TextStyle(
                                  color: Color(0xFF101820), fontSize: 16),
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
