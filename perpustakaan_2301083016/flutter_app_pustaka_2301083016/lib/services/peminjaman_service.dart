import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/peminjaman_model.dart';

class PeminjamanService {
  static const String baseUrl = 'http://localhost/flutter/perpustakaan_2301083016/pustaka_php/peminjaman.php';

  Future<List<Peminjaman>> getAllPeminjaman() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((json) => Peminjaman.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to load peminjaman');
    } catch (e) {
      throw Exception('Failed to load peminjaman: $e');
    }
  }

  Future<bool> createPeminjaman(Peminjaman peminjaman) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(peminjaman.toJson()),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to create peminjaman: $e');
    }
  }

  Future<bool> updatePeminjaman(Peminjaman peminjaman) async {
    try {
      final Map<String, String> formData = {
        'action': 'update',
        ...peminjaman.toJson()
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to update peminjaman: $e');
    }
  }

  Future<bool> deletePeminjaman(int id) async {
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
      throw Exception('Failed to delete peminjaman: $e');
    }
  }

  Future<bool> updateStatusPeminjaman(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id.toString(),
          'status': status,
          'action': 'update_status'
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to update peminjaman status: $e');
    }
  }
}
