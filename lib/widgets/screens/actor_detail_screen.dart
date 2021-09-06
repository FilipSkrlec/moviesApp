import 'package:flutter/material.dart';
import 'package:movies_app/assets/colors/colors.dart';
import 'package:movies_app/assets/texts/texts.dart';
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
                    widget.actorDetails["name"] ?? "",
                    style: TextStyle(color: yellowDetail, fontSize: 30),
                  )),
              CategoryNameWidget(
                  categoryName: categoryActorLabels["birthday"]!),
              CategoryDataWidget(
                  categoryData:
                      widget.actorDetails["birthday"] ?? unknownDataText),
              CategoryNameWidget(
                  categoryName: categoryActorLabels["place_of_birth"]!),
              CategoryDataWidget(
                  categoryData:
                      widget.actorDetails["place_of_birth"] ?? unknownDataText),
              CategoryNameWidget(
                  categoryName: categoryActorLabels["biography"]!),
              CategoryDataWidget(
                  categoryData:
                      widget.actorDetails["biography"] ?? unknownDataText),
              CategoryNameWidget(
                  categoryName: categoryActorLabels["top_movies"]!),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Text(
                    widget.actorDetails["top_movies"] ?? unknownDataText,
                    style: TextStyle(color: yellowDetail, fontSize: 20),
                  )),
            ],
          )
        ],
      )),
    );
  }
}
