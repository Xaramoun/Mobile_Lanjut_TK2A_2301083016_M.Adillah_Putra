import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/buku_model.dart';

class BukuService {
  static const String baseUrl = 'http://localhost/flutter/perpustakaan_2301083016/pustaka_php/buku.php';

  Future<List<Buku>> getAllBuku() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((json) => Buku.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to load buku');
    } catch (e) {
      throw Exception('Failed to load buku: $e');
    }
  }

  Future<bool> createBuku(Buku buku) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(buku.toJson()),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to create buku: $e');
    }
  }

  Future<bool> updateBuku(Buku buku) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(buku.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to update buku: $e');
    }
  }

  Future<bool> deleteBuku(int id) async {
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
      throw Exception('Failed to delete buku: $e');
    }
  }

  Future<Buku?> getBukuById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?action=get_by_id&id=$id'));
      print('Buku API Response: ${response.body}'); // Debug print
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success']) {
          return Buku.fromJson(data['data'][0]); // Ambil data pertama dari array
        }
      }
      return null;
    } catch (e) {
      print('Error in getBukuById: $e');
      return null;
    }
  }
}