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
        body: Stack(
          children: [
            Container(
              width: 300,
              height: 300,
              color: Colors.green,
            ),
            Container(
              width: 250,
              height: 250,
              color: Colors.yellow,
            ),
            Container(
              width: 200,
              height: 200,
              color: Colors.red,
            ),
          ],
        )
      ),
    );
  }
}

