class KelurahanModel {
  KelurahanModel({
    required this.kelurahan,
  });

  List<Kelurahan> kelurahan;

  factory KelurahanModel.fromJson(dynamic json) => KelurahanModel(
        kelurahan: List<Kelurahan>.from(json.map((x) => Kelurahan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "kelurahan": List<dynamic>.from(kelurahan.map((x) => x.toJson())),
      };
}

class Kelurahan {
  Kelurahan({
    required this.id,
    required this.idKecamatan,
    required this.nama,
  });

  int id;
  String idKecamatan;
  String nama;

  factory Kelurahan.fromJson(Map<String, dynamic> json) => Kelurahan(
        id: int.parse(json["id"]),
        idKecamatan: json["district_id"],
        nama: json["name"].replaceAll(RegExp('(Kelurahan) '), ''),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_kecamatan": idKecamatan,
        "nama": nama,
      };
}
