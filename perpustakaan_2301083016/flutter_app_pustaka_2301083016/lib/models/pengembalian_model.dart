class Pengembalian {
  final int? id;
  final int? idPeminjaman;
  final int? idBuku;
  final int? idAnggota;
  final String? tanggal_pengembalian;
  final int? terlambat;
  final double? denda;

  Pengembalian({
    this.id,
    this.idPeminjaman,
    this.idBuku,
    this.idAnggota,
    this.tanggal_pengembalian,
    this.terlambat,
    this.denda,
  });

  Map<String, dynamic> toJson() => {
    'id': id?.toString(),
    'id_peminjaman': idPeminjaman?.toString(),
    'tanggal_pengembalian': tanggal_pengembalian,
    'terlambat': terlambat?.toString(),
    'denda': denda?.toString(),
  };

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      id: json['id'],
      idPeminjaman: int.parse(json['id_peminjaman'].toString()),
      tanggal_pengembalian: json['tanggal_pengembalian'],
      terlambat: int.parse(json['terlambat'].toString()),
      denda: double.parse(json['denda'].toString()),
    );
  }
}
