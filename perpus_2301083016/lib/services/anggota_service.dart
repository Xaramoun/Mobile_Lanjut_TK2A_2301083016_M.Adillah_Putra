import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anggota_model.dart';

class AnggotaService {
  final String baseUrl = 'http://localhost/flutter/perpus_2301083016/api/anggota.php';

  Future<List<Anggota>> fetchAnggota() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Anggota.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load anggota');
    }
  }

  Future<void> addAnggota(Anggota anggota) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(anggota.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add anggota');
    }
  }
}