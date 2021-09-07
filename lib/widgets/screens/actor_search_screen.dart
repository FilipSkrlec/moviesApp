import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/assets/colors/colors.dart';
import 'package:movies_app/assets/texts/texts.dart';
import 'actor_detail_screen.dart';

class ActorSearchScreen extends StatefulWidget {
  final String title;
  final List<dynamic> actorSearchData;
  final String query;
  final String apiKey;

  const ActorSearchScreen(
      {Key? key,
      required this.title,
      required this.actorSearchData,
      required this.query,
      required this.apiKey})
      : super(key: key);

  @override
  _ActorSearchScreenState createState() => _ActorSearchScreenState();
}

class _ActorSearchScreenState extends State<ActorSearchScreen> {
  int _page = 2;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0) {
          getNextActorPage();
        }
      }
    });
  }

  void scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.linear);
  }

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

  Future getNextActorPage() async {
    var responseByActorQuery =
        await http.get(Uri.https('api.themoviedb.org', '3/search/person', {
      "api_key": widget.apiKey,
      "language": "en-US",
      "query": widget.query,
      "page": this._page.toString(),
    }));
    var jsonActorSearchData = jsonDecode(responseByActorQuery.body)["results"];

    setState(() {
      for (var actor in jsonActorSearchData) {
        widget.actorSearchData.add(actor);
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
          child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: TextButton(
                      onPressed: () => navigateToActorDetailScreen(context,
                          widget.actorSearchData[index]["id"].toString()),
                      child: Text(
                        widget.actorSearchData[index]["name"] ?? noDataText,
                        style: TextStyle(fontSize: 20),
                      )),
                );
              },
              itemCount: widget.actorSearchData.length)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellowDetail,
        onPressed: scrollToTop,
        tooltip: 'Go to top',
        child: Icon(Icons.arrow_upward_sharp),
      ),
    );
  }
}
