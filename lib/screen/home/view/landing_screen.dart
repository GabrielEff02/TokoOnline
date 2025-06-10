import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:project_skripsi/screen/gabriel/notifications/item_screen.dart';
import 'package:project_skripsi/screen/home/landing_home.dart';

import '../../../controller/landing_controller.dart';
import '../../../screen/gabriel/core/app_export.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final LandingScreenController controller = Get.put(LandingScreenController());
  List<dynamic> productData = [];
  List<Map<String, dynamic>> companyCode = [];
  String selectedCompanyCode = 'semua';
  Map<String, dynamic> categoryData = {};
  Future<void> loadInitialData() async {
    DialogConstant.loading(context, 'Loading...');
    await getCompan();
    await getProductData();
    await localDataCheck();
    Get.back();
  }

  Future<void> localDataCheck() async {
    if (await LocalData.containsKey('compan_code')) {
      final companCode = await LocalData.getData('compan_code');
      setState(() {
        selectedCompanyCode = companCode;
      });
    }
  }

  Future<void> getProductData() async {
    String companCode = 'all';

    if (await LocalData.containsKey('compan_code')) {
      companCode = await LocalData.getData('compan_code');
    }
    final fetchData = await CheckoutsData.getInitData(companCode);
    setState(() {
      productData = fetchData['productData'].toList();
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String truncateText(String text, {int maxLength = 15}) {
    return text.length > maxLength
        ? "${text.substring(0, maxLength)}..."
        : text;
  }

  Future<void> getCategoryData() async {
    final fetchData = await LandingScreenData.getCategoryData();
    setState(() {
      categoryData.addAll(<String, dynamic>{'All': 'All'});

      categoryData.addEntries(fetchData.entries);
      controller.categoryData.value = fetchData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.adaptSize),
            child: ListView(
              children: [
                SizedBox(height: 20.v),
                CarouselWidget(),
                SizedBox(height: 20.v),
                Container(
                  margin: EdgeInsets.all(8.adaptSize),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6C63FF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: Color(0xFF6C63FF),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Pilih Perusahaan",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          value: selectedCompanyCode,
                          icon: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(0xFF6C63FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF6C63FF),
                              size: 20,
                            ),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 8,
                          items: companyCode.map((company) {
                            return DropdownMenuItem<String>(
                              value: company["compan_code"],
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF6C63FF),
                                            Color(0xFF4F46E5)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.apartment,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        company["name"]!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCompanyCode = newValue!;
                            });
                            LocalData.saveData(
                                'compan_code', selectedCompanyCode);
                            loadInitialData();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.v),
                Column(children: productRow(productData).toList()),
                SizedBox(height: 80.v)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getCompan() async {
    try {
      final response =
          await http.get(Uri.parse('${API.BASE_URL}/api/toko/get_compan'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          companyCode = [
            {'compan_code': 'semua', 'name': 'Semua'}
          ];
          companyCode.addAll(jsonData.map((outlet) {
            return {
              'compan_code': outlet['compan_code'],
              'name': outlet['name']
            };
          }).toList());
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  List<Widget> productRow(List productData) {
    List<Widget> rows = [];

    for (int i = 0; i < productData.length; i += 2) {
      rows.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildProductCard(context, productData[i]),
              ),
              SizedBox(width: 16),
              if (i + 1 < productData.length)
                Expanded(
                  child: _buildProductCard(context, productData[i + 1]),
                )
              else
                Expanded(child: Container()),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    return Container(
      height: 300,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Get.to(ItemScreen(
            data: product.map((key, value) {
              return MapEntry(key, value.toString());
            }),
            isPoint: false,
          ));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImageView(
              imagePath: "${API.BASE_URL}/img/gambar_produk/${product['url']}",
              height: 150, // Adjust image height as needed
              width: double.infinity,
              alignment: Alignment.center,
            ),
            SizedBox(height: 12), // Space between image and text
            Text(
              maxLines: 2,
              product['nama'], // Product name
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Increase font size
                color: Colors.black87, // Darker text color
              ),
            ),
            SizedBox(height: 4), // Space between name and price
            Text(
              'Rp. ${currencyFormatter.format(product['harga'])}', // Product price
              style: TextStyle(
                fontSize: 16, // Font size for price
                color: Colors.green, // Green color for price
              ),
            ),
            SizedBox(height: 4), // Space between price and quantity
            Text(
              'Stok: ${product['quantity']} ${product['satuan']}', // Product quantity
              style: TextStyle(
                fontSize: 14, // Font size for quantity
                color: Colors.grey[600], // Grey color for quantity
              ),
            ),
          ],
        ),
      ),
    );
  }
}
