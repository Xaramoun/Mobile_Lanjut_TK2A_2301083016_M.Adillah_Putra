import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResultScreen extends StatelessWidget {
  final String kodePelanggan;
  final String namaPelanggan;
  final String jenisPelanggan;
  final DateTime tanggalMasuk;
  final TimeOfDay jamMasuk;
  final TimeOfDay jamKeluar;

  ResultScreen({
    required this.kodePelanggan,
    required this.namaPelanggan,
    required this.jenisPelanggan,
    required this.tanggalMasuk,
    required this.jamMasuk,
    required this.jamKeluar,
  });

  @override
  Widget build(BuildContext context) {
    final int tarifPerJam = 10000;
    final int lamaMinutes = (jamKeluar.hour * 60 + jamKeluar.minute) -
        (jamMasuk.hour * 60 + jamMasuk.minute);
    final int lamaJam = lamaMinutes ~/ 60;  // Integer division for hours
    final int lamaMenit = lamaMinutes % 60;  // Remainder for minutes
    final double lamajam = lamaMinutes / 60.0;
    double diskon = 0;

    // Diskon hanya untuk VIP dan GOLD
    if (jenisPelanggan != 'Regular') {
      if (jenisPelanggan == 'VIP' && lamajam > 2) {
        diskon = 0.02; // 2% discount
      } else if (jenisPelanggan == 'GOLD' && lamajam > 2) {
        diskon = 0.05; // 5% discount
      }
    }

    final double totalBayar = (lamajam * tarifPerJam) * (1 - diskon);

    // Format currency
    final currencyFormatter = NumberFormat('#,##0', 'id_ID');

    return Scaffold(
      appBar: AppBar(title: Text('Hasil Perhitungan')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode Pelanggan: $kodePelanggan'),
            Text('Nama Pelanggan: $namaPelanggan'),
            Text('Jenis Pelanggan: $jenisPelanggan'),
            Text('Tanggal Masuk: ${DateFormat('dd/MM/yyyy').format(tanggalMasuk)}'),
            Text('Jam Masuk: ${jamMasuk.format(context)}'),
            Text('Jam Keluar: ${jamKeluar.format(context)}'),
            Text('Lama: $lamaJam jam $lamaMenit menit'),
            Text('Tarif per Jam: Rp ${currencyFormatter.format(tarifPerJam)}'),
            Text('Diskon: ${(diskon * 100).toStringAsFixed(0)}%'),
            Text('Total Bayar: Rp ${currencyFormatter.format(totalBayar)}'),
          ],
        ),
      ),
    );
  }
}