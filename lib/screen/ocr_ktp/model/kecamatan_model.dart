class KecamatanModel {
  KecamatanModel({
    required this.kecamatan,
  });

  final List<Kecamatan> kecamatan;

  factory KecamatanModel.fromJson(dynamic json) => KecamatanModel(
        kecamatan: List<Kecamatan>.from(json.map((x) => Kecamatan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "kecamatan": List<dynamic>.from(kecamatan.map((x) => x.toJson())),
      };
}

class Kecamatan {
  Kecamatan({
    required this.id,
    required this.idKota,
    required this.nama,
  });

  final int id;
  final String idKota;
  final String nama;

  factory Kecamatan.fromJson(Map<String, dynamic> json) => Kecamatan(
        id: int.parse(json["id"]),
        idKota: json["regency_id"],
        nama: json["name"].replaceAll(RegExp('(Kecamatan) '), ''),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_kota": idKota,
        "nama": nama,
      };
}
