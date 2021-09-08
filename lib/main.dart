import 'package:flutter/material.dart';
import 'assets/colors/colors.dart';
import 'assets/texts/texts.dart';
import 'widgets/screens/home_page_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFFEE715, primaryMaterialColor),
      ),
      home: HomePageScreen(title: appTitle, apiKey: ""),
    );
  }
}
