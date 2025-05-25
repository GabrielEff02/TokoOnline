import 'dart:convert';
import 'package:project_skripsi/api/api.dart';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';
import 'package:http/http.dart' as http;

class OutletScreen extends StatefulWidget {
  @override
  _OutletScreenState createState() => _OutletScreenState();
}

class _OutletScreenState extends State<OutletScreen> {
  // URL untuk mengakses data dari API

  final String apiUrl = '${API.BASE_URL}/get_compan.php';

  Future<List<Map<String, dynamic>>> getCompan() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Mengonversi JSON response menjadi List<Map<String, dynamic>>
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((outlet) {
          return {
            'name': outlet['name'],
            'address': outlet['address'],
            'phone': outlet['phone'],
            'image_url': outlet['image_url']
          };
        }).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Outlet'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getCompan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan saat mengambil data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada outlet tersedia'));
          } else {
            final outlets = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: outlets.length,
              itemBuilder: (context, index) {
                return _buildOutletCard(outlets[index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildOutletCard(Map<String, dynamic> outlet) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImageView(
              imagePath: '${API.BASE_URL}/images/${outlet['image_url']}',
              height: 225.v,
              width: double.infinity,
              alignment: Alignment.center,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 12),
            Text(
              outlet['name']!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              outlet['address']!,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            if (outlet['phone'] != '-') ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 18, color: Colors.green),
                  SizedBox(width: 10),
                  Text(outlet['phone']!, style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
