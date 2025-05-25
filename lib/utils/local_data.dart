import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:convert';

class LocalData {
  static Future<bool> removeAllPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  static void saveDataBool(String param, bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(param, val);
  }

  static Future<bool> getDataBool(String param) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getBool(param);
    if (data != null) {
      return data;
    }
    return false;
  }

  static void saveData(String param, String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(param, val);
  }

  static Future<String> getData(String param) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString(param);
    if (data != null && data.isNotEmpty) {
      return data;
    }
    return '';
  }

  static Future<Uint8List> getProfilePicture(String param) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString(param); // Retrieve the Base64 string
    if (base64Image != null && base64Image.isNotEmpty) {
      return base64Decode(
          base64Image); // Convert Base64 string back to Uint8List
    }
    return base64Decode(""); // Return null if no image found
  }

  static void saveDataInt(String param, int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(param, val);
  }

  static Future<int> getDataInt(String param) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getInt(param);
    if (data != null) {
      return data;
    }
    return -1;
  }

  static Future<bool> containsKey(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  static Future<bool> removeData(String param) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(param);
  }
}
