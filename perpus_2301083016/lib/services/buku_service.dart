import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/buku_model.dart';

class BukuService {
  final String baseUrl = 'http://localhost/flutter/perpus_2301083016/api/buku.php';

  Future<List<Buku>> fetchBuku() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Buku.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load buku');
    }
  }

  Future<void> addBuku(Buku buku) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(buku.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add buku');
    }
  }
}