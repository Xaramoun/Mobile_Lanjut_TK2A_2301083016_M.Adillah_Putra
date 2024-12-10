import 'package:flutter/material.dart';
import '../models/buku_model.dart';
import '../services/buku_service.dart';

class BukuFormScreen extends StatefulWidget {
  final Buku? buku;

  BukuFormScreen({this.buku});

  @override
  _BukuFormScreenState createState() => _BukuFormScreenState();
}

class _BukuFormScreenState extends State<BukuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bukuService = BukuService();
  
  late TextEditingController _judulController;
  late TextEditingController _pengarangController;
  late TextEditingController _penerbitController;
  late TextEditingController _tahunTerbitController;
  late TextEditingController _urlGambarController;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.buku?.judul ?? '');
    _pengarangController = TextEditingController(text: widget.buku?.pengarang ?? '');
    _penerbitController = TextEditingController(text: widget.buku?.penerbit ?? '');
    _tahunTerbitController = TextEditingController(text: widget.buku?.tahun_terbit ?? '');
    _urlGambarController = TextEditingController(text: widget.buku?.url_gambar ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.buku == null ? 'Tambah Buku' : 'Edit Buku',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo, Colors.deepPurple],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTextField(
                        controller: _judulController,
                        label: 'Judul Buku',
                        icon: Icons.book,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul harus diisi';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      buildTextField(
                        controller: _pengarangController,
                        label: 'Nama Pengarang',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pengarang harus diisi';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      buildTextField(
                        controller: _penerbitController,
                        label: 'Penerbit',
                        icon: Icons.business,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Penerbit harus diisi';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      buildTextField(
                        controller: _tahunTerbitController,
                        label: 'Tahun Terbit',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tahun terbit harus diisi';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      buildTextField(
                        controller: _urlGambarController,
                        label: 'URL Gambar',
                        icon: Icons.image,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final buku = Buku(
                                id: widget.buku?.id,
                                judul: _judulController.text,
                                pengarang: _pengarangController.text,
                                penerbit: _penerbitController.text,
                                tahun_terbit: _tahunTerbitController.text,
                                url_gambar: _urlGambarController.text,
                              );

                              bool success;
                              if (widget.buku == null) {
                                success = await _bukuService.createBuku(buku);
                              } else {
                                success = await _bukuService.updateBuku(buku);
                              }

                              if (success) {
                                Navigator.pop(context, true);
                              } else {
                                throw Exception('Operasi gagal');
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        labelStyle: TextStyle(color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.indigo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.indigo.withOpacity(0.5)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
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
}