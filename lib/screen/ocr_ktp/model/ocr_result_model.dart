import 'dart:convert';
//*Model untuk mengambil data ktp, banyak data yang bisa di ambil berdasarkan list model di bawah ini*/

OcrResultModel ocrResultModelFromMap(String str) =>
    OcrResultModel.fromMap(json.decode(str));

String ocrResultModelToMap(OcrResultModel data) => json.encode(data.toMap());

final List<String> masterPekerjaan = [
  "Belum / Tidak Bekerja",
  "Mengurus Rumah Tangga",
  "Pelajar / Mahasiswa",
  "Pensiunan",
  "Pegawai Negeri Sipil",
  "Tentara Nasional Indonesia",
  "Kepolisian RI",
  "Perdagangan",
  "Petani / Pekebun",
  "Peternak",
  "Nelayan / Perikanan",
  "Industri",
  "Konstruksi",
  "Transportasi",
  "Karyawan Swasta",
  "Karyawan BUMN",
  "Karyawan BUMD",
  "Karyawan Honorer",
  "Buruh Harian Lepas",
  "Buruh Tani / Perkebunan",
  "Buruh Nelayan / Perikanan",
  "Buruh Peternakan",
  "Pembantu Rumah Tangga",
  "Tukang Cukur",
  "Tukang Listrik",
  "Tukang Batu",
  "Tukang Kayu",
  "Tukang Sol Sepatu",
  "Tukang Las / Pandai Besi",
  "Tukang Jahit",
  "Penata Rambut",
  "Penata Rias",
  "Penata Busana",
  "Mekanik",
  "Tukang Gigi",
  "Seniman",
  "Tabib",
  "Paraji",
  "Perancang Busana",
  "Penerjemah",
  "Imam Masjid",
  "Pendeta",
  "Pastur",
  "Wartawan",
  "Ustadz / Mubaligh",
  "Juru Masak",
  "Promotor Acara",
  "Anggota DPR-RI",
  "Anggota DPD",
  "Anggota BPK",
  "Presiden",
  "Wakil Presiden",
  "Anggota Mahkamah Konstitusi",
  "Anggota Kabinet / Kementerian",
  "Duta Besar",
  "Gubernur",
  "Wakil Gubernur",
  "Bupati",
  "Wakil Bupati",
  "Walikota",
  "Wakil Walikota",
  "Anggota DPRD Provinsi",
  "Anggota DPRD Kabupaten",
  "Dosen",
  "Guru",
  "Pilot",
  "Pengacara",
  "Notaris",
  "Arsitek",
  "Akuntan",
  "Konsultan",
  "Dokter",
  "Bidan",
  "Perawat",
  "Apoteker",
  "Psikiater / Psikolog",
  "Penyiar Televisi",
  "Penyiar Radio",
  "Pelaut",
  "Peneliti",
  "Sopir",
  "Pialang",
  "Paranormal",
  "Pedagang",
  "Perangkat Desa",
  "Kepala Desa",
  "Biarawati",
  "Wiraswasta",
  "Anggota Lembaga Tinggi",
  "Artis",
  "Atlit",
  "Chef",
  "Manajer",
  "Tenaga Tata Usaha",
  "Operator",
  "Pekerja Pengolahan, Kerajinan",
  "Teknisi",
  "Asisten Ahli",
  "Lainnya"
];
final List<String> masterAgama = [
  'Katolik',
  'Kristen',
  'Hindu',
  'Buddha',
  'Konghucu',
  'Islam'
];
final List<String> masterJenisKelamin = ['laki-laki', 'perempuan'];
final List<String> masterKewarganegaraan = ['WNI', 'WNA'];
final List<String> masterGolonganDarah = ['-', 'A', 'B', 'AB', 'O'];
final List<String> masterStatusPerkawinan = [
  'Belum Kawin',
  'Kawin',
  'Cerai Hidup',
  'cerai mati'
];

class OcrResultModel {
  OcrResultModel({
    required this.isSuccess,
    required this.errorMessage,
    required this.imagePath,
    required this.ktp,
  });

  final bool? isSuccess;
  final String? errorMessage;
  final String? imagePath;
  final Ktp? ktp;

  factory OcrResultModel.fromJson(String source) =>
      OcrResultModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  factory OcrResultModel.fromMap(Map<String, dynamic> json) => OcrResultModel(
        isSuccess: json["isSuccess"],
        errorMessage: json["errorMessage"],
        imagePath: json["imagePath"],
        ktp: Ktp.fromMap(json["ktp"]),
      );

  Map<String, dynamic> toMap() => {
        "isSuccess": isSuccess,
        "errorMessage": errorMessage,
        "imagePath": imagePath,
        "ktp": ktp?.toMap(),
      };
}

String parseRw(String rw) {
  final regExp = RegExp(r'(\d{3})|(\d{2}\s\d)|(\d{3}\/\d{3})|(\d{6})');
  final match = regExp.firstMatch(rw);

  if (match != null) {
    return match.group(0)!.replaceAll(RegExp(r'\s|\/'), '');
  }

  return '';
}

int distanceCount(String a, String b) {
  final List<List<int>> dp =
      List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));

  for (int i = 0; i <= a.length; i++) {
    dp[i][0] = i;
  }
  for (int j = 0; j <= b.length; j++) {
    dp[0][j] = j;
  }

  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      final cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
      dp[i][j] = [
        dp[i - 1][j] + 1, // Deletion
        dp[i][j - 1] + 1, // Insertion
        dp[i - 1][j - 1] + cost, // Substitution
      ].reduce((value, element) => value < element ? value : element);
    }
  }
  return dp[a.length][b.length];
}

String findClosestMatch(String input, List<String> candidates) {
  if (input.isNotEmpty) {
    String closestMatch = "";
    int lowestDistance = 10000000000000000;
    int distance = 0;
    for (var candidate in candidates) {
      distance = distanceCount(input.toLowerCase(), candidate.toLowerCase());
      if (distance < lowestDistance) {
        lowestDistance = distance;
        closestMatch = candidate;
      }
    }

    return closestMatch;
  } else {
    return "";
  }
}

class Ktp {
  Ktp({
    required this.nik,
    required this.nama,
    required this.tempatLahir,
    required this.golDarah,
    required this.tglLahir,
    required this.jenisKelamin,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.kelurahan,
    required this.kecamatan,
    required this.agama,
    required this.statusPerkawinan,
    required this.pekerjaan,
    required this.kewarganegaraan,
    required this.berlakuHingga,
    required this.provinsi,
    required this.kabKot,
  });

  final String? nik;
  final String? nama;
  final String? tempatLahir;
  final String? golDarah;
  final String? tglLahir;
  final String? jenisKelamin;
  final String? alamat;
  final String? rt;
  final String? rw;
  final String? kelurahan;
  final String? kecamatan;
  final String? agama;
  final String? statusPerkawinan;
  final String? pekerjaan;
  final String? kewarganegaraan;
  final String? berlakuHingga;
  final String? provinsi;
  final String? kabKot;

  factory Ktp.fromMap(Map<String, dynamic> json) => Ktp(
        nik: json["nik"],
        nama: json["nama"],
        tempatLahir: json["tempatLahir"],
        tglLahir: json["tglLahir"],
        alamat: json["alamat"],
        golDarah: findClosestMatch(json["golDarah"], masterGolonganDarah),
        jenisKelamin:
            findClosestMatch(json["jenisKelamin"], masterJenisKelamin),
        rt: json["rt"].toString().substring(0, 3),
        rw: parseRw(json["rw"]),
        agama: findClosestMatch(json["agama"], masterAgama),
        statusPerkawinan:
            findClosestMatch(json["statusPerkawinan"], masterStatusPerkawinan),
        pekerjaan: findClosestMatch(json["pekerjaan"], masterPekerjaan),
        kewarganegaraan:
            findClosestMatch(json["kewarganegaraan"], masterKewarganegaraan),
        provinsi: json["provinsi"],
        kabKot: json["kabKot"],
        kelurahan: json["kelurahan"],
        kecamatan: json["kecamatan"],
        berlakuHingga: json["berlakuHingga"],
      );

  Map<String, dynamic> toMap() => {
        "nik": nik,
        "nama": nama,
        "tempatLahir": tempatLahir,
        "golDarah": golDarah,
        "tglLahir": tglLahir,
        "jenisKelamin": jenisKelamin,
        "alamat": alamat,
        "rt": rt,
        "rw": rw,
        "kelurahan": kelurahan,
        "kecamatan": kecamatan,
        "agama": agama,
        "statusPerkawinan": statusPerkawinan,
        "pekerjaan": pekerjaan,
        "kewarganegaraan": kewarganegaraan,
        "berlakuHingga": berlakuHingga,
        "provinsi": provinsi,
        "kabKot": kabKot,
      };
}
