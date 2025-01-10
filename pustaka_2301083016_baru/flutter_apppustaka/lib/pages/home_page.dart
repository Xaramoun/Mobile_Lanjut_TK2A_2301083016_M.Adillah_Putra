import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/pustaka/databasepustaka/buku.php'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          books = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> addBook() async {
    final TextEditingController judulController = TextEditingController();
    final TextEditingController pengarangController = TextEditingController();
    final TextEditingController penerbitController = TextEditingController();
    final TextEditingController tahunController = TextEditingController();
    final TextEditingController urlGambarController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tambah Buku',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: judulController,
                  label: 'Judul Buku',
                  icon: Icons.book,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: pengarangController,
                  label: 'Pengarang',
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: penerbitController,
                  label: 'Penerbit',
                  icon: Icons.business,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: tahunController,
                  label: 'Tahun',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: urlGambarController,
                  label: 'URL Gambar',
                  icon: Icons.image,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final response = await http.post(
                            Uri.parse('http://localhost/pustaka/databasepustaka/buku.php'),
                            headers: {'Content-Type': 'application/json'},
                            body: json.encode({
                              'judul': judulController.text,
                              'pengarang': pengarangController.text,
                              'penerbit': penerbitController.text,
                              'tahun': tahunController.text,
                              'url_gambar': urlGambarController.text,
                              'status': 'Tersedia',
                            }),
                          );

                          if (response.statusCode == 200) {
                            Navigator.pop(context);
                            fetchBooks();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Buku berhasil ditambahkan'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> updateBook(Map<String, dynamic> book) async {
    final TextEditingController judulController = 
        TextEditingController(text: book['judul']);
    final TextEditingController pengarangController = 
        TextEditingController(text: book['pengarang']);
    final TextEditingController penerbitController = 
        TextEditingController(text: book['penerbit']);
    final TextEditingController tahunController = 
        TextEditingController(text: book['tahun']);
    final TextEditingController urlGambarController = 
        TextEditingController(text: book['url_gambar']);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Update Buku',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: judulController,
                  label: 'Judul',
                  icon: Icons.book,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: pengarangController,
                  label: 'Pengarang',
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: penerbitController,
                  label: 'Penerbit',
                  icon: Icons.business,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: tahunController,
                  label: 'Tahun',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: urlGambarController,
                  label: 'URL Gambar',
                  icon: Icons.image,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final response = await http.put(
                            Uri.parse('http://localhost/pustaka/databasepustaka/buku.php'),
                            headers: {'Content-Type': 'application/json'},
                            body: json.encode({
                              'id': book['id'],
                              'judul': judulController.text,
                              'pengarang': pengarangController.text,
                              'penerbit': penerbitController.text,
                              'tahun': tahunController.text,
                              'url_gambar': urlGambarController.text,
                            }),
                          );

                          if (response.statusCode == 200) {
                            Navigator.pop(context);
                            fetchBooks();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Buku berhasil diupdate'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteBook(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost/pustaka/databasepustaka/buku.php?id=$id'),
      );
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buku berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        fetchBooks();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addBook,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada data buku',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            book['url_gambar'] ?? 'https://via.placeholder.com/50',
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 70,
                                color: Colors.grey[200],
                                child: const Icon(Icons.book, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          book['judul'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pengarang: ${book['pengarang']}'),
                            Text('Penerbit: ${book['penerbit']} (${book['tahun']})'),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: book['status'] == 'Tersedia'
                                    ? Colors.green[50]
                                    : Colors.red[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                book['status'],
                                style: TextStyle(
                                  color: book['status'] == 'Tersedia'
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => updateBook(book),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus buku ini?'
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deleteBook(book['id']);
                                      },
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}