class Provinsi {
  Provinsi({
    required this.provinsi,
  });

  final List<ProvinsiElement> provinsi;

  factory Provinsi.fromJson(Map<String, dynamic> json) => Provinsi(
        provinsi: List<ProvinsiElement>.from(
            json["provinsi"].map((x) => ProvinsiElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "provinsi": List<dynamic>.from(provinsi.map((x) => x.toJson())),
      };
}

class ProvinsiElement {
  ProvinsiElement({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory ProvinsiElement.fromJson(Map<String, dynamic> json) =>
      ProvinsiElement(
        id: int.parse(json["id"]),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
