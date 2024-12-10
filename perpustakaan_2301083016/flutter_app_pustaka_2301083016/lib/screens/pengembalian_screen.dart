import 'package:flutter/material.dart';
import '../models/pengembalian_model.dart';
import '../services/pengembalian_service.dart';
import '../services/buku_service.dart';
import '../services/anggota_service.dart';

class PengembalianScreen extends StatefulWidget {
  @override
  _PengembalianScreenState createState() => _PengembalianScreenState();
}

class _PengembalianScreenState extends State<PengembalianScreen> {
  final PengembalianService _pengembalianService = PengembalianService();
  final BukuService _bukuService = BukuService();
  final AnggotaService _anggotaService = AnggotaService();
  late Future<List<Pengembalian>> _pengembalianList;

  @override
  void initState() {
    super.initState();
    _refreshPengembalianList();
  }

  void _refreshPengembalianList() {
    setState(() {
      _pengembalianList = _pengembalianService.getAllPengembalian();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengembalian',
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
        child: FutureBuilder<List<Pengembalian>>(
          future: _pengembalianList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Tidak ada data pengembalian', style: TextStyle(color: Colors.white)));
            }

            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pengembalian = snapshot.data![index];
                return Card(
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color.fromARGB(255, 107, 79, 246), Colors.blue.shade50],
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
                              Icon(Icons.book, color: Colors.indigo),
                              SizedBox(width: 8),
                              FutureBuilder(
                                future: _bukuService.getBukuById(pengembalian.idPeminjaman ?? 0),
                                builder: (context, bukuSnapshot) {
                                  if (bukuSnapshot.hasData) {
                                    return Text(
                                      'Buku: ${bukuSnapshot.data?.judul}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return Text('Loading...');
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.indigo),
                              SizedBox(width: 8),
                              FutureBuilder(
                                future: _anggotaService.getAnggotaById(pengembalian.idPeminjaman ?? 0),
                                builder: (context, anggotaSnapshot) {
                                  if (anggotaSnapshot.hasData) {
                                    return Text(
                                      'Peminjam: ${anggotaSnapshot.data?.nama}',
                                      style: TextStyle(fontSize: 16),
                                    );
                                  }
                                  return Text('Loading...');
                                },
                              ),
                            ],
                          ),
                          Divider(height: 20),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.indigo),
                              SizedBox(width: 8),
                              Text(
                                'Tanggal Kembali: ${pengembalian.tanggal_pengembalian}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: (pengembalian.terlambat ?? 0) > 0 ? Colors.red : Colors.green,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Terlambat: ${pengembalian.terlambat} hari',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: (pengembalian.terlambat ?? 0) > 0 ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.attach_money, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Denda: Rp${pengembalian.denda}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: Icon(Icons.delete, color: Colors.red),
                                label: Text('Hapus', style: TextStyle(color: Colors.red)),
                                onPressed: () async {
                                  if (await _confirmDelete(context)) {
                                    try {
                                      await _pengembalianService.deletePengembalian(pengembalian.id!);
                                      _refreshPengembalianList();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Pengembalian berhasil dihapus')),
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
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Yakin ingin menghapus data pengembalian ini?'),
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
}