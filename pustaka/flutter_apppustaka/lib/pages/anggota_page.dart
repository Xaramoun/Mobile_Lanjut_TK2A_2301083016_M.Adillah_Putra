import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnggotaPage extends StatefulWidget {
  const AnggotaPage({super.key});

  @override
  State<AnggotaPage> createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  List<dynamic> anggota = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost/pustaka/databasepustaka/anggota.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          anggota = data['data'];
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

  Future<void> deleteMember(String id) async {
    try {
      final response = await http.delete(
          Uri.parse('http://localhost/pustaka/databasepustaka/anggota.php?id=$id'));
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anggota berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        fetchMembers();
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

  Future<void> updateMember(Map<String, dynamic> member) async {
    final TextEditingController nimController = 
        TextEditingController(text: member['nim']);
    final TextEditingController namaController = 
        TextEditingController(text: member['nama']);
    final TextEditingController alamatController = 
        TextEditingController(text: member['alamat']);
    final TextEditingController jenisKelaminController = 
        TextEditingController(text: member['jenis_kelamin']);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Update Anggota',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nimController, 'NIM', Icons.numbers),
                const SizedBox(height: 10),
                _buildTextField(namaController, 'Nama', Icons.person),
                const SizedBox(height: 10),
                _buildTextField(alamatController, 'Alamat', Icons.location_on),
                const SizedBox(height: 10),
                _buildTextField(jenisKelaminController, 'Jenis Kelamin (L/P)', Icons.people),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final response = await http.put(
                    Uri.parse('http://localhost/pustaka/databasepustaka/anggota.php'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'id': member['id'],
                      'nim': nimController.text,
                      'nama': namaController.text,
                      'alamat': alamatController.text,
                      'jenis_kelamin': jenisKelaminController.text,
                    }),
                  );

                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anggota berhasil diupdate'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    fetchMembers();
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
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> addMember() async {
    final TextEditingController nimController = TextEditingController();
    final TextEditingController namaController = TextEditingController();
    final TextEditingController alamatController = TextEditingController();
    String selectedGender = 'L';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tambah Anggota',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(nimController, 'NIM', Icons.numbers),
                    const SizedBox(height: 10),
                    _buildTextField(namaController, 'Nama', Icons.person),
                    const SizedBox(height: 10),
                    _buildTextField(alamatController, 'Alamat', Icons.location_on),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Jenis Kelamin',
                        prefixIcon: const Icon(Icons.people, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                      ],
                      onChanged: (value) {
                        setState(() => selectedGender = value!);
                      },
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
                                Uri.parse('http://localhost/pustaka/databasepustaka/anggota.php'),
                                headers: {'Content-Type': 'application/json'},
                                body: json.encode({
                                  'nim': nimController.text,
                                  'nama': namaController.text,
                                  'alamat': alamatController.text,
                                  'jenis_kelamin': selectedGender,
                                }),
                              );

                              if (response.statusCode == 200) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Anggota berhasil ditambahkan'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                fetchMembers();
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Anggota'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addMember,
          ),
        ],
      ),
      body: Container(
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
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : anggota.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada data anggota',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: anggota.length,
                  itemBuilder: (context, index) {
                    final member = anggota[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            member['nama'][0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          member['nama'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NIM: ${member['nim']}'),
                            Text('Alamat: ${member['alamat']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => updateMember(member),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus anggota ini?'
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deleteMember(member['id']);
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
      ),
    );
  }
}