import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:project_skripsi/constant/dialog_constant.dart';
import 'package:project_skripsi/screen/auth/splash_screen.dart';
import 'package:project_skripsi/screen/gabriel/notifications/item_screen.dart';
import 'package:get/get.dart';

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

  Future<void> getCategoryData() async {
    await SplashScreen.getSplashData();

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
          await http.get(Uri.parse('${API.BASE_URL}/get_compan.php'));

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
              imagePath: "${API.BASE_URL}/images/gambar_brg/${product['url']}",
              height: 150, // Adjust image height as needed
              width: double.infinity,
              alignment: Alignment.center,
            ),
            SizedBox(height: 12), // Space between image and text
            Text(
              maxLines: 2,
              product['brg_name'], // Product name
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Increase font size
                color: Colors.black87, // Darker text color
              ),
            ),
            SizedBox(height: 4), // Space between name and price
            Text(
              'Rp. ${currencyFormatter.format(product['price'])}', // Product price
              style: TextStyle(
                fontSize: 16, // Font size for price
                color: Colors.green, // Green color for price
              ),
            ),
            SizedBox(height: 4), // Space between price and quantity
            Text(
              'Quantity: ${product['quantity']} ${product['per']}', // Product quantity
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
