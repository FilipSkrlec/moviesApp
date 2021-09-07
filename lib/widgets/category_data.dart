import 'package:flutter/material.dart';

class CategoryDataWidget extends StatefulWidget {
  final String categoryData;

  const CategoryDataWidget({Key? key, required this.categoryData})
      : super(key: key);

  @override
  _CategoryDataWidgetState createState() => _CategoryDataWidgetState();
}

class _CategoryDataWidgetState extends State<CategoryDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Text(
              widget.categoryData,
              style: TextStyle(color: Color(0xFFFEE715), fontSize: 20),
            )));
  }
}
