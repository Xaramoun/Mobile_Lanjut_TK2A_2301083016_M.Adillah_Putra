import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("My App"),
        ), // AppBar
        body: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Container(
              width: 300,
              height: 300,
              color: Colors.green,
            ),
            Container(
              width: 300,
              height: 300,
              color: Colors.yellow,
            ),
            Container(
              width: 300,
              height: 300,
              color: Colors.red,
            ),
          ],
        )
      ),
    );
  }
}

