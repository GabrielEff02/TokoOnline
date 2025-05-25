import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_skripsi/screen/ocr_ktp/model/kota_model.dart';

//*Controller untuk mengambil data kota dari link yang dimaksud */

class CityController extends GetxController {
  var cities = <City>[].obs;
  var selectedCity = Rxn<City>();

  fetchCities(id) async {
    var response = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$id.json'));
    var jsonData = json.decode(response.body);
    List<City> cityList =
        jsonData.map((c) => City.fromJson(c)).cast<City>().toList();
    cityList.sort((a, b) => a.name.compareTo(b.name));
    cities.value = cityList;
  }
}
