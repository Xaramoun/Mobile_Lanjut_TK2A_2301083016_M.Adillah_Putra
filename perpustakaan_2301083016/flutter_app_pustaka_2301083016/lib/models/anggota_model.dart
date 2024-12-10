class Anggota {
  final int? id;
  final String? nim;
  final String? nama;
  final String? alamat;
  final String? jenis_kelamin;

  Anggota({
    this.id,
    this.nim,
    this.nama,
    this.alamat,
    this.jenis_kelamin,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      nim: json['nim'].toString(),
      nama: json['nama'].toString(),
      alamat: json['alamat'].toString(),
      jenis_kelamin: json['jenis_kelamin'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nim': nim ?? '',
      'nama': nama ?? '',
      'alamat': alamat ?? '',
      'jenis_kelamin': jenis_kelamin ?? 'L',
    };
  }
}