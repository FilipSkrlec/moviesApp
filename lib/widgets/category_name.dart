import 'package:flutter/material.dart';

class CategoryNameWidget extends StatefulWidget {
  final String categoryName;
  const CategoryNameWidget({Key? key, required this.categoryName})
      : super(key: key);

  @override
  _CategoryNameWidgetState createState() => _CategoryNameWidgetState();
}

class _CategoryNameWidgetState extends State<CategoryNameWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: Text(
          widget.categoryName,
          style: TextStyle(color: Color(0xFFFEE715), fontSize: 24),
        ));
  }
}
