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
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 200,
              color: Colors.green,
            ),
            Container(
              width: 100,
              height: 250,
              color: Colors.yellow,
            ),
            Container(
              width: 55,
              height: 220,
              color: Colors.red,
            ),
          ],
        )
      ),
    );
  }
}

