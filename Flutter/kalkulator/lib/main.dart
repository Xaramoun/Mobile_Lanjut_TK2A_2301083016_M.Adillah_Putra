import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalculatorApp(),
    );
  }
}

class CalculatorApp extends StatefulWidget {
  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  TextEditingController _angka1Controller = TextEditingController();
  TextEditingController _angka2Controller = TextEditingController();
  String _hasil = '';

  void _hitung(String operator) {
    double angka1 = double.tryParse(_angka1Controller.text) ?? 0;
    double angka2 = double.tryParse(_angka2Controller.text) ?? 0;

    switch (operator) {
      case '+':
        _hasil = (angka1 + angka2).toString();
        break;
      case '-':
        _hasil = (angka1 - angka2).toString();
        break;
      case '*':
        _hasil = (angka1 * angka2).toString();
        break;
      case '/':
        if (angka2 != 0) {
          _hasil = (angka1 / angka2).toString();
        } else {
          _hasil = 'Error: Cannot divide by zero';
        }
        break;
      default:
        _hasil = 'Invalid operator';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulator Sederhana'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _angka1Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Angka 1'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _angka2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Angka 2'),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _hitung('+'),
                  child: Text('+'),
                ),
                ElevatedButton(
                  onPressed: () => _hitung('-'),
                  child: Text('-'),
                ),
                ElevatedButton(
                  onPressed: () => _hitung('*'),
                  child: Text('*'),
                ),
                ElevatedButton(
                  onPressed: () => _hitung('/'),
                  child: Text('/'),
                ),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Hasil: $_hasil',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}