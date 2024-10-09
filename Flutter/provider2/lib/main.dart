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
          title: Text('Kalkulator'),
        ),
        body: DiscountForm(),
      ),
    );
  }
}

class DiscountForm extends StatefulWidget {
  @override
  _DiscountFormState createState() => _DiscountFormState();
}

class _DiscountFormState extends State<DiscountForm> {
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _diskonController = TextEditingController();

  double _total = 0;
  double _diskonApplied = 0;

  void _hitungTotal() {
    double harga = double.tryParse(_hargaController.text) ?? 0;
    int jumlah = int.tryParse(_jumlahController.text) ?? 0;
    double diskon = double.tryParse(_diskonController.text) ?? 0;

    setState(() {
      _total = harga * jumlah;
      _diskonApplied = (_total * diskon) / 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _kodeController,
            decoration: InputDecoration(labelText: 'Kode Barang'),
          ),
          TextField(
            controller: _namaController,
            decoration: InputDecoration(labelText: 'Nama Barang'),
          ),
          TextField(
            controller: _hargaController,
            decoration: InputDecoration(labelText: 'Harga'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _jumlahController,
            decoration: InputDecoration(labelText: 'Jumlah'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _diskonController,
            decoration: InputDecoration(labelText: 'Diskon (%)'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _hitungTotal,
            child: Text('Proses'),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: TextStyle(fontSize: 18)),
              Text('Rp $_total', style: TextStyle(fontSize: 18)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diskon:', style: TextStyle(fontSize: 18)),
              Text('Rp $_diskonApplied', style: TextStyle(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}
