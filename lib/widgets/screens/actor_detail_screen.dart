import 'package:flutter/material.dart';
import 'package:movies_app/widgets/category_data.dart';
import 'package:movies_app/widgets/category_name.dart';

class ActorDetailScreen extends StatefulWidget {
  final String title;
  final Map<String, String> actorDetails;
  final String apiKey;

  const ActorDetailScreen(
      {Key? key,
      required this.title,
      required this.actorDetails,
      required this.apiKey})
      : super(key: key);

  @override
  _ActorDetailScreenState createState() => _ActorDetailScreenState();
}

class _ActorDetailScreenState extends State<ActorDetailScreen> {
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
                    widget.actorDetails["name"] ?? "",
                    style: TextStyle(color: Color(0xFFFEE715), fontSize: 30),
                  )),
              CategoryNameWidget(categoryName: "DATE OF BIRTH:"),
              CategoryDataWidget(
                  categoryData: widget.actorDetails["birthday"] ?? "unknown"),
              CategoryNameWidget(categoryName: "PLACE OF BIRTH:"),
              CategoryDataWidget(
                  categoryData:
                      widget.actorDetails["place_of_birth"] ?? "unknown"),
              CategoryNameWidget(categoryName: "BIOGRAPHY:"),
              CategoryDataWidget(
                  categoryData: widget.actorDetails["biography"] ?? "unknown"),
              CategoryNameWidget(categoryName: "TOP MOVIES:"),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Text(
                    widget.actorDetails["top_movies"] ?? "unknown",
                    style: TextStyle(color: Color(0xFFFEE715), fontSize: 20),
                  )),
            ],
          )
        ],
      )),
    );
  }
}
