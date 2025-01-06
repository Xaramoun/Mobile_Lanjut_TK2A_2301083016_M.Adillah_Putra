import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/buku_model.dart';

class BukuScreen extends StatefulWidget {
  @override
  _BukuScreenState createState() => _BukuScreenState();
}

class _BukuScreenState extends State<BukuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _pengarangController = TextEditingController();
  final _penerbitController = TextEditingController();
  final _tahunTerbitController = TextEditingController();
  final _urlGambarController = TextEditingController();

  Future<List<Buku>> getBuku() async {
    final response = await http.get(
      Uri.parse('http://localhost/flutter/perpus_2301083016/API/buku.php')
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Buku.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load buku');
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _pengarangController.dispose();
    _penerbitController.dispose();
    _tahunTerbitController.dispose();
    _urlGambarController.dispose();
    super.dispose();
  }

  Future<void> _addBuku() async {
    try {
      print('Sending data to API...');
      final requestData = {
        'judul': _judulController.text,
        'pengarang': _pengarangController.text,
        'penerbit': _penerbitController.text,
        'tahun_terbit': _tahunTerbitController.text,
        'url_gambar': _urlGambarController.text.isNotEmpty ? _urlGambarController.text : null,
      };
      print('Request data: $requestData');

      final response = await http.post(
        Uri.parse('http://localhost/flutter/perpus_2301083016/API/buku.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Navigator.pop(context);
        setState(() {
          // Refresh the list
          getBuku();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buku berhasil ditambahkan')),
        );
      } else {
        var errorMessage = 'Gagal menambahkan buku';
        try {
          final errorResponse = json.decode(response.body);
          if (errorResponse['error'] != null) {
            errorMessage = errorResponse['error'];
          }
        } catch (e) {
          print('Error parsing response: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error during API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddDialog() {
    _judulController.clear();
    _pengarangController.clear();
    _penerbitController.clear();
    _tahunTerbitController.clear();
    _urlGambarController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Buku'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _judulController,
                  decoration: InputDecoration(labelText: 'Judul'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _pengarangController,
                  decoration: InputDecoration(labelText: 'Pengarang'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pengarang tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _penerbitController,
                  decoration: InputDecoration(labelText: 'Penerbit'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Penerbit tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _tahunTerbitController,
                  decoration: InputDecoration(labelText: 'Tahun Terbit'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tahun terbit tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _urlGambarController,
                  decoration: InputDecoration(labelText: 'URL Gambar'),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      bool isValidUrl = Uri.tryParse(value)?.hasAbsolutePath ?? false;
                      if (!isValidUrl) {
                        return 'URL tidak valid';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _addBuku();
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Buku',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.purple.shade200,
            ],
          ),
        ),
        child: FutureBuilder<List<Buku>>(
          future: getBuku(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final buku = snapshot.data![index];
                  return Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.blue.shade50,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (buku.urlGambar != null && buku.urlGambar!.isNotEmpty)
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15.0),
                                  ),
                                  child: Container(
                                    color: Colors.white,
                                    child: Image.network(
                                      buku.urlGambar!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.grey.shade300, Colors.grey.shade200],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.book,
                                            size: 40,
                                            color: Colors.grey.shade400,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(15.0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    buku.judul,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  _buildInfoText('Pengarang:', buku.pengarang),
                                  _buildInfoText('Penerbit:', buku.penerbit),
                                  _buildInfoText('Tahun:', buku.tahunTerbit),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Text(
      '$label $value',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade700,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}