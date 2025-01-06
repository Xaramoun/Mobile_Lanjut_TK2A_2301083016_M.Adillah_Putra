class Anggota {
  final String nim;
  final String nama;
  final String alamat;
  final String jenisKelamin;

  Anggota({
    required this.nim,
    required this.nama,
    required this.alamat,
    required this.jenisKelamin,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      nim: json['nim'].toString(),
      nama: json['nama'].toString(),
      alamat: json['alamat'].toString(),
      jenisKelamin: json['jenis_kelamin'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nim': nim,
      'nama': nama,
      'alamat': alamat,
      'jenis_kelamin': jenisKelamin,
    };
  }
}