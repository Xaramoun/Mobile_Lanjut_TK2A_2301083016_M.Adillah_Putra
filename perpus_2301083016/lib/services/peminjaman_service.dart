import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/peminjaman_model.dart';

class PeminjamanService {
  final String baseUrl = 'http://localhost/flutter/perpus_2301083016/api/peminjaman.php';

  Future<List<Peminjaman>> fetchPeminjaman() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Peminjaman.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load peminjaman');
    }
  }

  Future<void> addPeminjaman(Peminjaman peminjaman) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(peminjaman.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add peminjaman');
    }
  }
}