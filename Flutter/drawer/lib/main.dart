import 'package:drawer/page_satu.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
      title: Text("Drawer"),
     ),
     drawer: Drawer(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Text("Menu Pilihan", style: TextStyle(fontSize: 24),),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PageSatu(),));
            },
            leading: Icon(Icons.home),
            title: Text("Home"),
          )
        ],
      ),
     ),
    );
  }
}
