class City {
  int id;
  String idProvinsi;
  String name;

  City({required this.id, required this.idProvinsi, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: int.parse(json['id']),
      idProvinsi: json['province_id'],
      name: json['name'].replaceAll(RegExp('(Kabupaten|Kota) '), ''),
    );
  }
}
