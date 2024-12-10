class Peminjaman {
  final int? id;
  final String? tanggalPinjam;
  final String? tanggalKembali;
  final int? idBuku;
  final int? idAnggota;
  String? status;

  Peminjaman({
    this.id,
    this.tanggalPinjam,
    this.tanggalKembali,
    this.idBuku,
    this.idAnggota,
    this.status,
  });

  Map<String, String> toJson() => {
    'id': id?.toString() ?? '',
    'tanggal_pinjam': tanggalPinjam ?? '',
    'tanggal_kembali': tanggalKembali ?? '',
    'id_buku': idBuku?.toString() ?? '',
    'id_anggota': idAnggota?.toString() ?? '',
    'status': status ?? '',
  };

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: int.tryParse(json['id'].toString()),
      tanggalPinjam: json['tanggal_pinjam'],
      tanggalKembali: json['tanggal_kembali'],
      idBuku: int.tryParse(json['id_buku'].toString()),
      idAnggota: int.tryParse(json['id_anggota'].toString()),
      status: json['status'],
    );
  }
}
