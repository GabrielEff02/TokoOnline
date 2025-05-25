import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_skripsi/screen/ocr_ktp/model/provinsi_model.dart';

//*Controller untuk mengambil data provinsi dari link yang dimaksud */

class ProvinceController extends GetxController {
  var provinces = <ProvinsiElement>[].obs;
  var selectedProvince = Rxn<ProvinsiElement>();

  @override
  void onInit() {
    super.onInit();
    fetchProvinces();
  }

  void fetchProvinces() async {
    var url = 'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<dynamic> provinsiList = jsonData;
      provinsiList.sort((a, b) => a['name'].compareTo(b['name']));

      provinces.value =
          provinsiList.map((e) => ProvinsiElement.fromJson(e)).toList();
    }
  }
}
