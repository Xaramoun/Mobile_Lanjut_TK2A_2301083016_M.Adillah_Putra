import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anggota_model.dart';

class AnggotaService {
  static const String baseUrl = 'http://localhost/flutter/perpustakaan_2301083016/pustaka_php/anggota.php';

  Future<List<Anggota>> getAllAnggota() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((json) => Anggota.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to load anggota');
    } catch (e) {
      throw Exception('Failed to load anggota: $e');
    }
  }

  Future<bool> createAnggota(Anggota anggota) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(anggota.toJson()),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to create anggota: $e');
    }
  }

  Future<bool> updateAnggota(Anggota anggota) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(anggota.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to update anggota: $e');
    }
  }

  Future<bool> deleteAnggota(int id) async {
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
      throw Exception('Failed to delete anggota: $e');
    }
  }

  Future<Anggota?> getAnggotaById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?action=get_by_id&id=$id'));
      print('Anggota API Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success']) {
          return Anggota.fromJson(data['data'][0]);
        }
      }
      return null;
    } catch (e) {
      print('Error in getAnggotaById: $e');
      return null;
    }
  }
}
