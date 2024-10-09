import 'package:flutter/material.dart';
import 'entry_screen.dart';

void main() {
  runApp(WarnetBillingApp());
}

class WarnetBillingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warnet Billing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EntryScreen(),
    );
  }
}