import 'package:flutter/material.dart';
import 'package:routes/gallery_page.dart';
import 'package:routes/home_page.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      routes: {
        '/homepage': (context) => HomePage(),
        '/gallery': (context) => GalleryPage(),
      },
    );
  }
}