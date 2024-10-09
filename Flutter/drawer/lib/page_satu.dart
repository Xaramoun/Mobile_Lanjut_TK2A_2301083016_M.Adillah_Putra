
import 'package:drawer/main.dart';
import 'package:flutter/material.dart';


class PageSatu extends StatelessWidget{
  @override
  Widget build (BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Page 1"),
      ),
      body: Center(
        child: Text("Ini Page 1"),
      ),
      floatingActionButton: FloatingActionButton(onPressed:() {
        Navigator.of(context).push(
          MaterialPageRoute(builder:(context){
            return HomePage();
          },)
        );
      },child: Icon(Icons.keyboard_arrow_right)),
    );
  }
}
