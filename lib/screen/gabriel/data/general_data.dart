import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../api/api.dart';
import '../../../utils/local_data.dart';

String db = API.BASE_URL;

class CheckoutsData {
  static Future<Map<String, dynamic>> getPointData(String compan_code) async {
    String username = await LocalData.getData('user');
    String companCode = await LocalData.getData('compan_code');
    if (companCode.isNotEmpty) {
      compan_code = companCode;
    }
    try {
      final response = await http.get(Uri.parse(
          "$db/checkouts_data.php?username=$username&compan_code=$compan_code"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final transactions = data['initData'] as Map<String, dynamic>;
        return transactions;
      } else {
        throw Exception('Failed to load transaction data');
      }
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> getInitData(String compan_code) async {
    String username = await LocalData.getData('user');
    String companCode = await LocalData.getData('compan_code');

    if (companCode.isNotEmpty) {
      compan_code = companCode;
    }
    if (companCode == 'semua') {
      compan_code = 'all';
    }
    try {
      final response = await http.get(Uri.parse(
          "$db/data.php?username=$username&compan_code=$compan_code"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final transactions = data['initData'] as Map<String, dynamic>;
        return transactions;
      } else {
        throw Exception('Failed to load transaction data');
      }
    } catch (e) {
      return {};
    }
  }
}

class LandingScreenData {
  static Future<Map<String, dynamic>> getCategoryData() async {
    try {
      var response = await http.get(Uri.parse("$db/landing_data.php"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final transactions = data as Map<String, dynamic>;
        return transactions;
      } else {
        throw Exception('Failed to load transaction data');
      }
    } catch (e) {
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getCarouselData() async {
    try {
      var response = await http.get(Uri.parse("$db/carousel_data.php"));

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        return data;
      } else {
        throw Exception('Failed to load transaction data');
      }
    } catch (e) {
      return [];
    }
  }
}

class Splash {
  static Future<List<String>> getSplashData() async {
    try {
      var response = await http.get(Uri.parse("$db/splash_data.php"));

      if (response.statusCode == 200) {
        List<String> data = List<String>.from(json.decode(response.body));
        return data;
      } else {
        throw Exception('Failed to load transaction data');
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getNotification() async {
    try {
      var username = await LocalData.getData('user');
      var response = await http
          .get(Uri.parse("$db/get_notification.php?username=" + username));
      if (response.statusCode == 200) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(json.decode(response.body));
        return data;
      } else {
        throw Exception('Failed to load transaction data');
      }
    } catch (e) {
      return {};
    }
  }
}
