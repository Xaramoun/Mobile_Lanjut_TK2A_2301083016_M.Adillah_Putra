import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/anggota_model.dart';

class AnggotaScreen extends StatefulWidget {
  @override
  _AnggotaScreenState createState() => _AnggotaScreenState();
}

class _AnggotaScreenState extends State<AnggotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  String _selectedJenisKelamin = 'L';

  Future<List<Anggota>> getAnggota() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/flutter/perpus_2301083016/API/anggota.php')
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        print('API Response: ${response.body}'); // Debug print
        return jsonResponse.map((data) => Anggota.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load anggota: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching anggota: $e'); // Debug print
      throw Exception('Failed to load anggota: $e');
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    _nimController.clear();
    _namaController.clear();
    _alamatController.clear();
    _selectedJenisKelamin = 'L';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Anggota'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nimController,
                    decoration: InputDecoration(labelText: 'NIM'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'NIM tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(labelText: 'Nama'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _alamatController,
                    decoration: InputDecoration(labelText: 'Alamat'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedJenisKelamin,
                    decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                    items: [
                      DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedJenisKelamin = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih jenis kelamin';
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  print('Form validated, sending data to API...');
                  try {
                    final requestData = {
                      'nim': _nimController.text,
                      'nama': _namaController.text,
                      'alamat': _alamatController.text,
                      'jenis_kelamin': _selectedJenisKelamin,
                    };
                    print('Request data: $requestData');

                    final response = await http.post(
                      Uri.parse('http://localhost/flutter/perpus_2301083016/API/anggota.php'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(requestData),
                    );

                    print('Response status: ${response.statusCode}');
                    print('Response body: ${response.body}');

                    if (response.statusCode == 200) {
                      Navigator.pop(context);
                      setState(() {
                        getAnggota();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Anggota berhasil ditambahkan')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menambahkan anggota: ${response.body}'),
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
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anggota Perpustakaan'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade100],
          ),
        ),
        child: FutureBuilder<List<Anggota>>(
          future: getAnggota(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, color: Colors.white, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada data anggota',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final anggota = snapshot.data![index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade800,
                      child: Text(
                        anggota.nama.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      anggota.nama,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.badge, size: 16, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('NIM: ${anggota.nim}'),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(child: Text(anggota.alamat)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(anggota.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan'),
                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade800,
      ),
    );
  }
}