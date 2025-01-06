import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pengembalian_model.dart';

class PengembalianService {
  final String baseUrl = 'http://localhost/flutter/perpus_2301083016/api/pengembalian.php';

  Future<List<Pengembalian>> fetchPengembalian() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Pengembalian.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load pengembalian');
    }
  }

  Future<void> addPengembalian(Pengembalian pengembalian) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(pengembalian.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add pengembalian');
    }
  }
}