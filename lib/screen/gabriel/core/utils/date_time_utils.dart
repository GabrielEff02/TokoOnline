import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class DateTimeUtils {
  static late DateTime dateTime;

  // Metode statis untuk mendapatkan waktu di Indonesia
  static Future<void> getTimeInIndonesia() async {
    const url = 'http://worldtimeapi.org/api/timezone/Asia/Jakarta';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      dateTime = DateTime.parse(data['datetime']).add(const Duration(hours: 7));
    } else {
      dateTime = DateTime.now();
    }
  }
}
