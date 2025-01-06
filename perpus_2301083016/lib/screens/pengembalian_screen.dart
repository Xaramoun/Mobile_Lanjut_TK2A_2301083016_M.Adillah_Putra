import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/peminjaman_model.dart';
import '../models/pengembalian_model.dart';

class PengembalianScreen extends StatefulWidget {
  @override
  _PengembalianScreenState createState() => _PengembalianScreenState();
}

class _PengembalianScreenState extends State<PengembalianScreen> {
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2';
    }
    return 'http://localhost';
  }

  Future<List<Map<String, dynamic>>> getPeminjaman() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/flutter/perpus_2301083016/API/peminjaman.php')
      );

      print('Peminjaman Response status: ${response.statusCode}');
      print('Peminjaman Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map<Map<String, dynamic>>((data) {
          // Calculate terlambat and denda
          DateTime tanggalKembali = DateTime.parse(data['tanggal_kembali']);
          DateTime now = DateTime.now();
          int terlambat = now.difference(tanggalKembali).inDays;
          double denda = terlambat > 0 ? terlambat * 1000 : 0; // Denda 1000 per hari

          return {
            ...data,
            'terlambat': terlambat > 0 ? terlambat : 0,
            'denda': denda,
          };
        }).toList();
      } else {
        throw Exception('Failed to load peminjaman: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getPeminjaman: $e');
      rethrow;
    }
  }

  Future<void> processPengembalian(Map<String, dynamic> data) async {
    try {
      print('Original data: $data');
      
      // Convert data types to match database requirements
      int idPeminjaman = int.parse(data['id'].toString());
      int terlambat = data['terlambat'] is int ? data['terlambat'] : int.parse(data['terlambat'].toString());
      double denda = data['denda'] is double ? data['denda'] : double.parse(data['denda'].toString());
      
      final requestData = {
        'id_peminjaman': idPeminjaman,
        'tanggal_pengembalian': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'terlambat': terlambat,
        'denda': denda,
        'keterangan': 'Buku dikembalikan pada ${DateFormat('dd-MM-yyyy').format(DateTime.now())}'
      };
      
      print('Sending data to server: ${json.encode(requestData)}');
      
      // First, create pengembalian record
      final pengembalianResponse = await http.post(
        Uri.parse('$baseUrl/flutter/perpus_2301083016/API/pengembalian.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      print('Response status: ${pengembalianResponse.statusCode}');
      print('Response body: ${pengembalianResponse.body}');

      if (pengembalianResponse.statusCode == 200) {
        // Then update peminjaman status
        await updateStatus(idPeminjaman.toString());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buku berhasil dikembalikan')),
        );
        
        setState(() {}); // Refresh the list
      } else {
        throw Exception('Failed to process pengembalian: ${pengembalianResponse.statusCode} - ${pengembalianResponse.body}');
      }
    } catch (e) {
      print('Error in processPengembalian: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateStatus(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/flutter/perpus_2301083016/API/update_peminjaman.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'status': 'Dikembalikan'
        }),
      );

      print('Update status response: ${response.statusCode}');
      print('Update status body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update peminjaman status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in updateStatus: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengembalian Buku', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[50]!],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getPeminjaman(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Memuat data peminjaman...',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final peminjaman = snapshot.data!;
            
            if (peminjaman.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_books, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada buku yang dipinjam',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: peminjaman.length,
              itemBuilder: (context, index) {
                final item = peminjaman[index];
                final bool isLate = item['terlambat'] > 0;
                
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isLate 
                          ? [Colors.red[50]!, Colors.white]
                          : [Colors.blue[50]!, Colors.white],
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            item['judul_buku'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isLate ? Colors.red[700] : Colors.blue[700],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    'Peminjam: ${item['nama_anggota']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    'Dipinjam: ${dateFormat.format(DateTime.parse(item['tanggal_pinjam']))}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    'Jatuh Tempo: ${dateFormat.format(DateTime.parse(item['tanggal_kembali']))}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              if (isLate) ...[
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.warning, size: 16, color: Colors.red[700]),
                                      SizedBox(width: 4),
                                      Text(
                                        'Terlambat ${item['terlambat']} hari',
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.attach_money, size: 16, color: Colors.red[700]),
                                      SizedBox(width: 4),
                                      Text(
                                        'Denda: Rp ${item['denda'].toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLate ? Colors.red[700] : Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline),
                                SizedBox(width: 8),
                                Text(
                                  'Kembalikan Buku',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () async {
                              await processPengembalian(item);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}