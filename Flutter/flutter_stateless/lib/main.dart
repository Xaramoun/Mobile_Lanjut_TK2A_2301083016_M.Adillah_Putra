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
        body: Center(
          child: Text("This Is My First Project",
          //maxLines: 2,
          //overflow: TextOverflow.ellipsis,
          style: TextStyle(
            backgroundColor: Colors.amber,
            color: Colors.white,
            fontSize: 30
          ),),
        ),
      ),
    );
  }
}

