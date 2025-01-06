class Pengembalian {
  final int id;
  final DateTime tanggalDikembalikan;
  final int terlambat;
  final double denda;
  final int peminjaman;

  Pengembalian({
    required this.id,
    required this.tanggalDikembalikan,
    required this.terlambat,
    required this.denda,
    required this.peminjaman,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      id: json['id'],
      tanggalDikembalikan: DateTime.parse(json['tanggal_dikembalikan']),
      terlambat: json['terlambat'],
      denda: json['denda'],
      peminjaman: json['peminjaman'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal_dikembalikan': tanggalDikembalikan.toIso8601String(),
      'terlambat': terlambat,
      'denda': denda,
      'peminjaman': peminjaman,
    };
  }
}