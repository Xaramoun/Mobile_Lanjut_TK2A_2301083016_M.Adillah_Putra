import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("List Tile"),
        ), // AppBar
        body: ListView(
          children: [
            ListTile(
              title: Text("M.Adillah Putra"),
              subtitle: Text("This Is Subtitle Okay.."),
              leading: CircleAvatar(),
              trailing: Text("10:00 PM"),
            ),
          ],
        )
      ),
    );
  }
}

