import 'package:flutter/material.dart';
import '../models/peminjaman_model.dart';
import '../models/anggota_model.dart';
import '../models/buku_model.dart';
import '../models/pengembalian_model.dart';
import '../services/peminjaman_service.dart';
import '../services/anggota_service.dart';
import '../services/buku_service.dart';
import '../services/pengembalian_service.dart';
import 'package:intl/intl.dart';

class PeminjamanScreen extends StatefulWidget {
  @override
  _PeminjamanScreenState createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  final PeminjamanService _peminjamanService = PeminjamanService();
  final AnggotaService _anggotaService = AnggotaService();
  final BukuService _bukuService = BukuService();
  final PengembalianService _pengembalianService = PengembalianService();

  late Future<List<Peminjaman>> _peminjamanList;
  late Future<List<Anggota>> _anggotaList;
  late Future<List<Buku>> _bukuList;

  @override
  void initState() {
    super.initState();
    _refreshPeminjamanList();
    _anggotaList = _anggotaService.getAllAnggota();
    _bukuList = _bukuService.getAllBuku();
  }

  void _refreshPeminjamanList() {
    setState(() {
      _peminjamanList = _peminjamanService.getAllPeminjaman();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Peminjaman',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          )
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
        child: FutureBuilder<List<Peminjaman>>(
          future: _peminjamanList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada data peminjaman',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final peminjaman = snapshot.data![index];
                return Card(
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color.fromARGB(255, 137, 115, 248), Colors.blue.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.book,
                                  color: Colors.indigo,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: FutureBuilder<Buku?>(
                                  future: _bukuService.getBukuById(peminjaman.idBuku!),
                                  builder: (context, bukuSnapshot) {
                                    return Text(
                                      bukuSnapshot.data?.judul ?? 'Loading...',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade900,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 20),
                          Row(
                            children: [
                              Icon(Icons.person,
                                size: 20,
                                color: Colors.indigo.shade700,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: FutureBuilder<Anggota?>(
                                  future: _anggotaService.getAnggotaById(peminjaman.idAnggota!),
                                  builder: (context, anggotaSnapshot) {
                                    return Text(
                                      anggotaSnapshot.data?.nama ?? 'Loading...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.indigo.shade700,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                      size: 20,
                                      color: Colors.indigo.shade600,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Pinjam: ${peminjaman.tanggalPinjam}',
                                      style: TextStyle(
                                        color: Colors.indigo.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.event,
                                      size: 20,
                                      color: Colors.indigo.shade600,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Kembali: ${peminjaman.tanggalKembali}',
                                      style: TextStyle(
                                        color: Colors.indigo.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: Icon(Icons.assignment_return, color: Colors.green),
                                label: Text('Kembalikan',
                                  style: TextStyle(color: Colors.green),
                                ),
                                onPressed: () => _handlePengembalian(peminjaman),
                              ),
                              SizedBox(width: 8),
                              TextButton.icon(
                                icon: Icon(Icons.delete, color: Colors.red),
                                label: Text('Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  if (await _confirmDelete(context)) {
                                    try {
                                      await _peminjamanService.deletePeminjaman(peminjaman.id!);
                                      _refreshPeminjamanList();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Peminjaman berhasil dihapus')),
                                      );
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
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                size: 20,
                                color: peminjaman.status == 'Dikembalikan' 
                                  ? Colors.green 
                                  : Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Status: ${peminjaman.status ?? "Dipinjam"}',
                                style: TextStyle(
                                  color: peminjaman.status == 'Dikembalikan' 
                                    ? Colors.green 
                                    : const Color.fromARGB(255, 42, 39, 234),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 81, 143, 235),
        child: Icon(Icons.add),
        onPressed: () => _showFormDialog(context, null),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Yakin ingin menghapus peminjaman ini?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showFormDialog(BuildContext context, Peminjaman? peminjaman) {
    final _formKey = GlobalKey<FormState>();
    final _tanggalPinjamController = TextEditingController(
      text: peminjaman?.tanggalPinjam ?? ''
    );
    final _tanggalKembaliController = TextEditingController(
      text: peminjaman?.tanggalKembali ?? ''
    );
    int? _selectedBukuId = peminjaman?.idBuku;
    int? _selectedAnggotaId = peminjaman?.idAnggota;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.blue.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      peminjaman == null ? 'Tambah Peminjaman' : 'Edit Peminjaman',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Pinjam',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _tanggalPinjamController,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today, color: Colors.indigo),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.date_range, color: Colors.indigo),
                              onPressed: () => _selectDate(context, _tanggalPinjamController),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'Tanggal Pinjam harus diisi' : null,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tanggal Kembali',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _tanggalKembaliController,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.event, color: Colors.indigo),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.date_range, color: Colors.indigo),
                              onPressed: () => _selectDate(context, _tanggalKembaliController),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'Tanggal Kembali harus diisi' : null,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Pilih Buku',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        FutureBuilder<List<Buku>>(
                          future: _bukuList,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return CircularProgressIndicator();
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonFormField<int>(
                                value: _selectedBukuId,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.book, color: Colors.indigo),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: snapshot.data!.map((buku) {
                                  return DropdownMenuItem<int>(
                                    value: buku.id,
                                    child: Text(buku.judul ?? ''),
                                  );
                                }).toList(),
                                onChanged: (value) => _selectedBukuId = value,
                                validator: (value) => value == null ? 'Pilih Buku harus diisi' : null,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Pilih Anggota',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        FutureBuilder<List<Anggota>>(
                          future: _anggotaList,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return CircularProgressIndicator();
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonFormField<int>(
                                value: _selectedAnggotaId,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person, color: Colors.indigo),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: snapshot.data!.map((anggota) {
                                  return DropdownMenuItem<int>(
                                    value: anggota.id,
                                    child: Text(anggota.nama ?? ''),
                                  );
                                }).toList(),
                                onChanged: (value) => _selectedAnggotaId = value,
                                validator: (value) => value == null ? 'Pilih Anggota harus diisi' : null,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 116, 164, 254),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    final newPeminjaman = Peminjaman(
                                      id: peminjaman?.id,
                                      tanggalPinjam: _tanggalPinjamController.text,
                                      tanggalKembali: _tanggalKembaliController.text,
                                      idBuku: _selectedBukuId,
                                      idAnggota: _selectedAnggotaId,
                                    );

                                    if (peminjaman == null) {
                                      await _peminjamanService.createPeminjaman(newPeminjaman);
                                    } else {
                                      await _peminjamanService.updatePeminjaman(newPeminjaman);
                                    }

                                    Navigator.pop(context);
                                    _refreshPeminjamanList();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          peminjaman == null
                                              ? 'Peminjaman berhasil ditambahkan'
                                              : 'Peminjaman berhasil diupdate',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                'Simpan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _handlePengembalian(Peminjaman peminjaman) async {
    try {
      final tanggalKembali = DateTime.parse(peminjaman.tanggalKembali!);
      final sekarang = DateTime.now();
      final selisihHari = sekarang.difference(tanggalKembali).inDays;
      final terlambat = selisihHari > 0 ? selisihHari : 0;
      final denda = terlambat * 1000.0;

      final pengembalian = Pengembalian(
        idPeminjaman: peminjaman.id!,
        tanggal_pengembalian: DateFormat('yyyy-MM-dd').format(sekarang),
        terlambat: terlambat,
        denda: denda,
      );

      final success = await _pengembalianService.createPengembalian(pengembalian);
      
      if (success) {
        _refreshPeminjamanList();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Buku berhasil dikembalikan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error in handlePengembalian: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengembalikan buku: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
