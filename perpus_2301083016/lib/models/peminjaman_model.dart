class Peminjaman {
  final String id;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final String anggota;
  final String buku;
  final String namaAnggota;
  final String judulBuku;
  final String status;

  Peminjaman({
    required this.id,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    required this.anggota,
    required this.buku,
    required this.namaAnggota,
    required this.judulBuku,
    required this.status,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: json['id'].toString(),
      tanggalPinjam: DateTime.parse(json['tanggal_pinjam']),
      tanggalKembali: DateTime.parse(json['tanggal_kembali']),
      anggota: json['anggota'].toString(),
      buku: json['buku'].toString(),
      namaAnggota: json['nama_anggota'].toString(),
      judulBuku: json['judul_buku'].toString(),
      status: json['status'] ?? 'Dipinjam',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal_pinjam': tanggalPinjam.toIso8601String(),
      'tanggal_kembali': tanggalKembali.toIso8601String(),
      'anggota': anggota,
      'buku': buku,
      'nama_anggota': namaAnggota,
      'judul_buku': judulBuku,
      'status': status,
    };
  }
}