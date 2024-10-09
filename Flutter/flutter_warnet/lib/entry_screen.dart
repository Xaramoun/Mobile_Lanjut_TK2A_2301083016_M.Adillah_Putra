import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'result_screen.dart';

class EntryScreen extends StatefulWidget {
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String kodePelanggan = '';
  String namaPelanggan = '';
  String jenisPelanggan = 'Regular';
  DateTime tanggalMasuk = DateTime.now();
  TimeOfDay jamMasuk = TimeOfDay.now();
  TimeOfDay jamKeluar = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Kode Pelanggan'),
              onSaved: (value) => kodePelanggan = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Nama Pelanggan'),
              onSaved: (value) => namaPelanggan = value!,
            ),
            DropdownButtonFormField<String>(
              value: jenisPelanggan,
              items: ['Regular', 'VIP', 'GOLD'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  jenisPelanggan = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Jenis Pelanggan'),
            ),
            ListTile(
              title: Text('Tanggal Masuk: ${DateFormat('dd/MM/yyyy').format(tanggalMasuk)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: tanggalMasuk,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (picked != null) {
                  setState(() {
                    tanggalMasuk = picked;
                  });
                }
              },
            ),
            ListTile(
              title: Text('Jam Masuk: ${jamMasuk.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: jamMasuk,
                );
                if (picked != null) {
                  setState(() {
                    jamMasuk = picked;
                  });
                }
              },
            ),
            ListTile(
              title: Text('Jam Keluar: ${jamKeluar.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: jamKeluar,
                );
                if (picked != null) {
                  setState(() {
                    jamKeluar = picked;
                  });
                }
              },
            ),
            ElevatedButton(
              child: Text('Hitung'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                        kodePelanggan: kodePelanggan,
                        namaPelanggan: namaPelanggan,
                        jenisPelanggan: jenisPelanggan,
                        tanggalMasuk: tanggalMasuk,
                        jamMasuk: jamMasuk,
                        jamKeluar: jamKeluar,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}