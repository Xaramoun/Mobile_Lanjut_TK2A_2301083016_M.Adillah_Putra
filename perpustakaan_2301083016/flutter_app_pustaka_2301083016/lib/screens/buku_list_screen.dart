import 'package:flutter/material.dart';
import '../models/buku_model.dart';
import '../services/buku_service.dart';
import 'buku_form_screen.dart';

class BukuListScreen extends StatefulWidget {
  @override
  _BukuListScreenState createState() => _BukuListScreenState();
}

class _BukuListScreenState extends State<BukuListScreen> {
  final BukuService _bukuService = BukuService();
  late Future<List<Buku>> _bukuList;

  @override
  void initState() {
    super.initState();
    _refreshBukuList();
  }

  void _refreshBukuList() {
    setState(() {
      _bukuList = _bukuService.getAllBuku();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Buku', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          )
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo, Colors.deepPurple],
          ),
        ),
        child: FutureBuilder<List<Buku>>(
          future: _bukuList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Tidak ada buku'));
            }

            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final buku = snapshot.data![index];
                return Card(
                  elevation: 12,
                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color.fromARGB(255, 150, 102, 247), Colors.blue.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              buku.url_gambar ?? '',
                              width: 130,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 130,
                                    height: 180,
                                    color: Colors.grey.shade200,
                                    child: Icon(Icons.book, size: 50, color: Colors.indigo),
                                  ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  buku.judul ?? '',
                                  style: TextStyle(
                                    color: Colors.indigo.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Oleh: ${buku.pengarang}',
                                  style: TextStyle(
                                    color: Colors.indigo.shade700,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Tahun: ${buku.tahun_terbit}',
                                  style: TextStyle(
                                    color: Colors.indigo.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: const Color.fromARGB(255, 25, 29, 226)),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BukuFormScreen(buku: buku),
                                          ),
                                        );
                                        if (result == true) {
                                          _refreshBukuList();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Konfirmasi'),
                                            content: Text('Hapus buku ini?'),
                                            actions: [
                                              TextButton(
                                                child: Text('Batal'),
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                              ),
                                              TextButton(
                                                child: Text('Hapus'),
                                                onPressed: () =>
                                                    Navigator.pop(context, true),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          try {
                                            await _bukuService.deleteBuku(buku.id!);
                                            _refreshBukuList();
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
        backgroundColor: const Color.fromARGB(255, 32, 180, 243),
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BukuFormScreen(),
            ),
          );
          if (result == true) {
            _refreshBukuList();
          }
        },
      ),
    );
  }
}