import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
}



class MainApp extends StatelessWidget{
  final List<Container> myList = List.generate(
  90,
  (index) { 
    return Container(
    color: Color.fromARGB(255, Random().nextInt(256), Random().nextInt(256),
    Random().nextInt(256)),
  );
  },
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Gridview"),
        ), // AppBar
        body: GridView(
          padding: EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 10,
            childAspectRatio: 4 / 3
          ),
          children: myList,
        )),
    );
  }
  }