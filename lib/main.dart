import 'package:flutter/material.dart';
import 'assets/texts/texts.dart';
import 'widgets/screens/home_page_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Map<int, Color> primaryMaterialColor = {
    50: Color(0xFFF49F1C),
    100: Color(0xFFF49F1C),
    200: Color(0xFFF49F1C),
    300: Color(0xFFF49F1C),
    400: Color(0xFFF49F1C),
    500: Color(0xFFF49F1C),
    600: Color(0xFFF49F1C),
    700: Color(0xFFF49F1C),
    800: Color(0xFFF49F1C),
    900: Color(0xFFF49F1C),
  };

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
