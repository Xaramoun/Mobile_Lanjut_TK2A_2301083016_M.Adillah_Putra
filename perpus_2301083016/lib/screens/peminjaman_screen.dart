import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/peminjaman_model.dart';

class PeminjamanScreen extends StatefulWidget {
  @override
  _PeminjamanScreenState createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  String? _selectedAnggota;
  String? _selectedBuku;
  DateTime _tanggalPinjam = DateTime.now();
  DateTime _tanggalKembali = DateTime.now().add(Duration(days: 7));
  List<Map<String, dynamic>> _anggotaList = [];
  List<Map<String, dynamic>> _bukuList = [];

  Future<List<Peminjaman>> getPeminjaman() async {
    final response = await http.get(
      Uri.parse('http://localhost/flutter/perpus_2301083016/API/peminjaman.php')
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Peminjaman.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load peminjaman');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAnggota();
    _fetchBuku();
  }

  Future<void> _fetchAnggota() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/flutter/perpus_2301083016/API/anggota.php')
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _anggotaList = data.map((item) => {
            'id': item['id'].toString(),
            'nama': item['nama'].toString(),
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching anggota: $e');
    }
  }

  Future<void> _fetchBuku() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/flutter/perpus_2301083016/API/buku.php')
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _bukuList = data.map((item) => {
            'id': item['id'].toString(),
            'judul': item['judul'].toString(),
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching buku: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _tanggalPinjam : _tanggalKembali,
      firstDate: DateTime(2020),  
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _tanggalPinjam = picked;
        } else {
          if (picked.isBefore(_tanggalPinjam)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tanggal kembali tidak boleh sebelum tanggal pinjam'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            _tanggalKembali = picked;
          }
        }
      });
    }
  }

  Future<void> _addPeminjaman() async {
    try {
      if (_selectedAnggota == null || _selectedBuku == null || 
          _tanggalPinjam == null || _tanggalKembali == null) {
        throw Exception('Semua field harus diisi');
      }

      print('Sending peminjaman data to API...');
      final requestData = {
        'id_anggota': _selectedAnggota,
        'id_buku': _selectedBuku,
        'tanggal_pinjam': DateFormat('yyyy-MM-dd').format(_tanggalPinjam!),
        'tanggal_kembali': DateFormat('yyyy-MM-dd').format(_tanggalKembali!),
      };
      print('Request data: $requestData');

      final response = await http.post(
        Uri.parse('http://localhost/flutter/perpus_2301083016/API/peminjaman.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Navigator.pop(context);
        setState(() {
          getPeminjaman();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Peminjaman berhasil ditambahkan')),
        );
      } else {
        var errorMessage = 'Gagal menambahkan peminjaman';
        try {
          final errorResponse = json.decode(response.body);
          if (errorResponse['error'] != null) {
            errorMessage = errorResponse['error'];
          }
        } catch (e) {
          print('Error parsing response: $e');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error during API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Peminjaman'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAnggota,
                decoration: InputDecoration(labelText: 'Pilih Anggota'),
                items: _anggotaList.map((anggota) {
                  return DropdownMenuItem<String>(
                    value: anggota['id'],
                    child: Text(anggota['nama']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAnggota = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silakan pilih anggota';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBuku,
                decoration: InputDecoration(labelText: 'Pilih Buku'),
                items: _bukuList.map((buku) {
                  return DropdownMenuItem<String>(
                    value: buku['id'],
                    child: Text(buku['judul']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBuku = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silakan pilih buku';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Tanggal Pinjam'),
                subtitle: Text(dateFormat.format(_tanggalPinjam)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              SizedBox(height: 8),
              ListTile(
                title: Text('Tanggal Kembali'),
                subtitle: Text(dateFormat.format(_tanggalKembali)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addPeminjaman();
                  }
                },
                child: Text('Tambah Peminjaman'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peminjaman Buku', style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: FutureBuilder<List<Peminjaman>>(
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
                        'Belum ada peminjaman buku',
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
                          colors: [Colors.blue[50]!, Colors.white],
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              item.judulBuku,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
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
                                      'Peminjam: ${item.namaAnggota}',
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
                                      'Tanggal Pinjam: ${DateFormat('dd-MM-yyyy').format(item.tanggalPinjam)}',
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
                                      'Jatuh Tempo: ${DateFormat('dd-MM-yyyy').format(item.tanggalKembali)}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.status == 'Dipinjam' ? Colors.green[100] : Colors.orange[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        item.status == 'Dipinjam' ? Icons.check_circle : Icons.pending,
                                        size: 16,
                                        color: item.status == 'Dipinjam' ? Colors.green[700] : Colors.orange[700],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Status: ${item.status}',
                                        style: TextStyle(
                                          color: item.status == 'Dipinjam' ? Colors.green[700] : Colors.orange[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        label: Text('Pinjam Buku', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}