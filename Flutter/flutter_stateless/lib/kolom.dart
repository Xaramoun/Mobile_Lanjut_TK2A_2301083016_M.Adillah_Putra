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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 20,
              color: Colors.green,
            ),
            Container(
              width: 100,
              height: 20,
              color: Colors.yellow,
            ),
            Container(
              width: 50,
              height: 20,
              color: Colors.red,
            ),
          ],
        )
      ),
    );
  }
}

