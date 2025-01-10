import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  List<dynamic> peminjaman = [];
  List<dynamic> anggota = [];
  List<dynamic> buku = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('PeminjamanPage initState called');
    fetchPeminjaman();
    fetchAnggota();
    fetchBuku();
  }

  Future<void> fetchPeminjaman() async {
    try {
      setState(() {
        isLoading = true;  // Set loading state
      });
      
      print('Fetching peminjaman data...');
      final url = 'http://localhost/pustaka/databasepustaka/peminjaman.php';
      print('Request URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data: $data');
        
        if (data['success'] == true) {
          setState(() {
            peminjaman = data['data'] ?? [];
            print('Peminjaman data length: ${peminjaman.length}');
            isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Unknown error occurred');
        }
      } else {
        throw Exception('Failed to load peminjaman: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching peminjaman: $e');
      setState(() {
        isLoading = false;
        peminjaman = [];
      });
      // Tambahkan SnackBar untuk menampilkan error ke user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> fetchAnggota() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost/pustaka/databasepustaka/anggota.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          anggota = data['data'];
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchBuku() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost/pustaka/databasepustaka/buku.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          buku = data['data'];
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addPeminjaman() async {
    String? selectedAnggotaId;
    String? selectedBukuId;
    DateTime? tanggalPinjam;
    DateTime? tanggalKembali;

    if (anggota.isEmpty) await fetchAnggota();
    if (buku.isEmpty) await fetchBuku();

    if (!context.mounted) return;
    
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Peminjaman',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setStateDialog) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown Anggota
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                          hintText: 'Pilih Anggota',
                        ),
                        value: selectedAnggotaId,
                        items: anggota.map((item) => DropdownMenuItem(
                          value: item['id'].toString(),
                          child: Text(item['nama'] ?? ''),
                        )).toList(),
                        onChanged: (value) {
                          setStateDialog(() => selectedAnggotaId = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Dropdown Buku
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                          hintText: 'Pilih Buku',
                        ),
                        value: selectedBukuId,
                        items: buku.map((item) => DropdownMenuItem(
                          value: item['id'].toString(),
                          child: Text(item['judul'] ?? ''),
                        )).toList(),
                        onChanged: (value) {
                          setStateDialog(() => selectedBukuId = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Tanggal Pinjam
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal Pinjam',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setStateDialog(() => tanggalPinjam = date);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            width: double.infinity,
                            child: Text(
                              tanggalPinjam?.toString().split(' ')[0] ?? 'Pilih tanggal',
                              style: TextStyle(
                                color: tanggalPinjam != null ? Colors.black87 : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tanggal Kembali
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal Kembali',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tanggalPinjam ?? DateTime.now(),
                              firstDate: tanggalPinjam ?? DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setStateDialog(() => tanggalKembali = date);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            width: double.infinity,
                            child: Text(
                              tanggalKembali?.toString().split(' ')[0] ?? 'Pilih tanggal',
                              style: TextStyle(
                                color: tanggalKembali != null ? Colors.black87 : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Batal',
                      style: TextStyle(color: Colors.blue[400]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () async {
                      if (selectedAnggotaId != null && 
                          selectedBukuId != null && 
                          tanggalPinjam != null && 
                          tanggalKembali != null) {
                        try {
                          final response = await http.post(
                            Uri.parse('http://localhost/pustaka/databasepustaka/peminjaman.php'),
                            headers: {'Content-Type': 'application/json'},
                            body: json.encode({
                              'anggota': selectedAnggotaId,
                              'buku': selectedBukuId,
                              'tanggal_pinjam': tanggalPinjam!.toString().split(' ')[0],
                              'tanggal_kembali': tanggalKembali!.toString().split(' ')[0],
                            }),
                          );

                          if (response.statusCode == 200) {
                            final data = json.decode(response.body);
                            if (data['success']) {
                              Navigator.pop(context);
                              fetchPeminjaman();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Peminjaman berhasil ditambahkan')));
                            } else {
                              throw Exception(data['message']);
                            }
                          } else {
                            throw Exception('Failed to add peminjaman');
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mohon lengkapi semua data')));
                      }
                    },
                    child: Text(
                      'Tambah',
                      style: TextStyle(color: Colors.blue[400]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tambahkan fungsi untuk menghitung denda
  int hitungDenda(String tanggalKembali, String tanggalDikembalikan) {
    final kembali = DateTime.parse(tanggalKembali);
    final dikembalikan = DateTime.parse(tanggalDikembalikan);
    final selisihHari = dikembalikan.difference(kembali).inDays;
    
    // Jika terlambat, denda 5000 per hari
    return selisihHari > 0 ? selisihHari * 5000 : 0;
  }

  // Tambahkan fungsi untuk proses pengembalian
  Future<void> prosesKembalikan(Map<String, dynamic> pinjam) async {
    final now = DateTime.now();
    final tanggalKembali = DateTime.parse(pinjam['tanggal_kembali']);
    final terlambat = now.isAfter(tanggalKembali) ? 'Ya' : 'Tidak';
    final denda = hitungDenda(pinjam['tanggal_kembali'], now.toString().split(' ')[0]);

    try {
        // Simpan data pengembalian
        final responsePengembalian = await http.post(
            Uri.parse('http://localhost/pustaka/databasepustaka/pengembalian.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
                'peminjaman': pinjam['id'],
                'tanggal_dikembalikan': now.toString().split(' ')[0],
                'terlambat': terlambat,
                'denda': denda,
            }),
        );

        if (responsePengembalian.statusCode == 200) {
            final dataPengembalian = json.decode(responsePengembalian.body);
            if (dataPengembalian['success']) {
                // Hapus data peminjaman
                final responseDelete = await http.delete(
                    Uri.parse('http://localhost/pustaka/databasepustaka/peminjaman.php?id=${pinjam['id']}'),
                );

                if (responseDelete.statusCode == 200) {
                    setState(() {
                        peminjaman.removeWhere((item) => item['id'] == pinjam['id']);
                    });
                    if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Buku berhasil dikembalikan${denda > 0 ? '. Denda: Rp${NumberFormat('#,###').format(denda)}' : ''}'
                                ),
                            ),
                        );
                    }
                } else {
                    throw Exception('Gagal menghapus data peminjaman');
                }
            } else {
                throw Exception(dataPengembalian['message']);
            }
        }
    } catch (e) {
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Daftar Peminjaman',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade500,
                ],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : peminjaman.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data peminjaman',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: peminjaman.length,
                    itemBuilder: (context, index) {
                      final pinjam = peminjaman[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    pinjam['judul_buku'] ?? 'No Title',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Tombol Kembalikan
                                      IconButton(
                                        icon: Icon(
                                          Icons.assignment_return,
                                          color: Colors.blue[400],
                                          size: 20,
                                        ),
                                        onPressed: () => showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Konfirmasi Pengembalian'),
                                              content: const Text('Yakin ingin mengembalikan buku ini?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    prosesKembalikan(pinjam);
                                                  },
                                                  child: const Text('Kembalikan'),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      // Tombol Hapus yang sudah ada
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                        onPressed: () => showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Konfirmasi'),
                                              content: const Text('Yakin ingin menghapus data peminjaman ini?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    try {
                                                      final response = await http.delete(
                                                        Uri.parse(
                                                          'http://localhost/pustaka/databasepustaka/peminjaman.php?id=${pinjam['id']}'),
                                                      );
                                                      
                                                      if (response.statusCode == 200) {
                                                        if (context.mounted) {
                                                          Navigator.pop(context);
                                                          fetchPeminjaman();
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Peminjaman berhasil dihapus')));
                                                        }
                                                      }
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Error: $e')));
                                                      }
                                                    }
                                                  },
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Peminjam: ${pinjam['nama_anggota'] ?? 'No Name'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tanggal Pinjam: ${pinjam['tanggal_pinjam'] ?? '-'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tanggal Kembali: ${pinjam['tanggal_kembali'] ?? '-'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: addPeminjaman,
          backgroundColor: Colors.blue[100],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, color: Colors.blue),
        ),
      ),
    );
  }
}
