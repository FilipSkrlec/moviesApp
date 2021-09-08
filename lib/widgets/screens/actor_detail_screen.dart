import 'package:cached_network_image/cached_network_image.dart';
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
  ScrollController _scrollController = ScrollController();

  void scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.linear);
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
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        children: <Widget>[
          Center(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: yellowDetail),
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  child: Text(
                    widget.actorDetails["name"] ?? "",
                    style: TextStyle(color: yellowDetail, fontSize: 30),
                  ))),
          CachedNetworkImage(
            placeholder: (context, url) => CircularProgressIndicator(),
            imageUrl: "https://image.tmdb.org/t/p/w500" +
                widget.actorDetails["profile_path"]!,
          ),
          CategoryNameWidget(categoryName: categoryActorLabels["birthday"]!),
          CategoryDataWidget(
              categoryData: widget.actorDetails["birthday"] ?? unknownDataText),
          CategoryNameWidget(
              categoryName: categoryActorLabels["place_of_birth"]!),
          CategoryDataWidget(
              categoryData:
                  widget.actorDetails["place_of_birth"] ?? unknownDataText),
          CategoryNameWidget(categoryName: categoryActorLabels["biography"]!),
          CategoryDataWidget(
              categoryData:
                  widget.actorDetails["biography"] ?? unknownDataText),
          CategoryNameWidget(categoryName: categoryActorLabels["top_movies"]!),
          Center(
              child: Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Text(
                    widget.actorDetails["top_movies"] ?? unknownDataText,
                    style: TextStyle(color: yellowDetail, fontSize: 20),
                  ))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellowDetail,
        onPressed: scrollToTop,
        tooltip: scrollTopTooltip,
        child: Icon(Icons.arrow_upward_sharp),
      ),
    );
  }
}
