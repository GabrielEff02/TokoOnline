import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_skripsi/screen/ocr_ktp/model/kecamatan_model.dart';

//*Controller untuk mengambil data kecamatan dari link yang dimaksud */
class KecamatanController extends GetxController {
  final _kecamatanModel = KecamatanModel(kecamatan: []).obs;
  KecamatanModel get kecamatanModel => _kecamatanModel.value;
  set kecamatanModel(value) => _kecamatanModel.value = value;

  final _selectedKecamatan = Rxn<int>();
  int? get selectedKecamatan => _selectedKecamatan.value;
  set selectedKecamatan(int? value) => _selectedKecamatan.value = value;

  final _selectedKecamatanName = Rxn<String>();
  String? get selectedKecamatanName => _selectedKecamatanName.value;
  set selectedKecamatanName(String? value) =>
      _selectedKecamatanName.value = value;
  Future<void> fetchKecamatanModel(int idKota) async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$idKota.json'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData != null && jsonData is List) {
          List<dynamic> kecamatanList = jsonData;
          kecamatanList.sort((a, b) => a['name'].compareTo(b['name']));

          jsonData = kecamatanList;
        }

        kecamatanModel = KecamatanModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load KecamatanModel');
      }
    } catch (e) {
      throw Exception('Failed to load KecamatanModel');
    }
  }
}
