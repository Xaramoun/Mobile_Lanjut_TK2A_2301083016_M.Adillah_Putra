import 'package:aplikasi/page_dua.dart';
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
            return PageDua();
          },)
        );
      },child: Icon(Icons.keyboard_arrow_right)),
    );
  }
}
