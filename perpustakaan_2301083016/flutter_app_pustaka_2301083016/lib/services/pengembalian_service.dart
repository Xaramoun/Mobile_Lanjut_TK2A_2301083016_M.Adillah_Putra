import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pengembalian_model.dart';

class PengembalianService {
  static const String baseUrl = 'http://localhost/flutter/perpustakaan_2301083016/pustaka_php/pengembalian.php';

  Future<List<Pengembalian>> getAllPengembalian() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((json) => Pengembalian.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to load pengembalian');
    } catch (e) {
      throw Exception('Failed to load pengembalian: $e');
    }
  }

  Future<bool> createPengembalian(Pengembalian pengembalian) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(pengembalian.toJson()),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to create pengembalian: $e');
    }
  }

  Future<bool> updatePengembalian(Pengembalian pengembalian) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(pengembalian.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to update pengembalian: $e');
    }
  }

  Future<bool> deletePengembalian(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl?id=$id'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete pengembalian: $e');
    }
  }
}
