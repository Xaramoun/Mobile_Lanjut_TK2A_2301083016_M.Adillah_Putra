class Buku {
  final int? id;
  final String? judul;
  final String? pengarang;
  final String? penerbit;
  final String? tahun_terbit;
  final String? url_gambar;

  Buku({
    this.id,
    this.judul,
    this.pengarang,
    this.penerbit,
    this.tahun_terbit,
    this.url_gambar,
  });

  factory Buku.fromJson(Map<String, dynamic> json) {
    return Buku(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      judul: json['judul']?.toString() ?? '',
      pengarang: json['pengarang']?.toString() ?? '',
      penerbit: json['penerbit']?.toString() ?? '',
      tahun_terbit: json['tahun_terbit']?.toString() ?? '',
      url_gambar: json['url_gambar']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'judul': judul ?? '',
      'pengarang': pengarang ?? '',
      'penerbit': penerbit ?? '',
      'tahun_terbit': tahun_terbit ?? '',
      'url_gambar': url_gambar ?? '',
    };
  }
}