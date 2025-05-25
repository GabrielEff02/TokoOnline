import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_skripsi/screen/ocr_ktp/model/kelurahan_model.dart';

//*Controller untuk mengambil data kelurahan dari link yang dimaksud */

class KelurahanController extends GetxController {
  final _kelurahanModel = KelurahanModel(kelurahan: []).obs;
  KelurahanModel get kelurahanModel => _kelurahanModel.value;
  set kelurahanModel(value) => _kelurahanModel.value = value;

  final _selectedKelurahan = Rxn<String>();
  String? get selectedKelurahan => _selectedKelurahan.value;
  set selectedKelurahan(String? value) => _selectedKelurahan.value = value;
  Future<void> fetchKelurahanModel(int idKecamatan) async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/villages/$idKecamatan.json'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        List<dynamic> kelurahanList = jsonData;
        kelurahanList.sort((a, b) => a['name'].compareTo(b['name']));
        jsonData = kelurahanList;

        kelurahanModel = KelurahanModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load KecamatanModel');
      }
    } catch (e) {
      throw Exception('Failed to load KecamatanModel');
    }
  }
}
