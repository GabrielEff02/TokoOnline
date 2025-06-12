import 'dart:math';

import 'package:project_skripsi/constant/dialog_constant.dart';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';
import 'package:project_skripsi/screen/gabriel/notifications/item_screen.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckoutMainScreen extends StatefulWidget {
  const CheckoutMainScreen({super.key});

  @override
  State<CheckoutMainScreen> createState() => _CheckoutMainScreenState();
}

class _CheckoutMainScreenState extends State<CheckoutMainScreen> {
  List<dynamic> productData = [];
  List<Map<String, dynamic>> companyCode = [];
  String selectedCompanyCode = 'semua';
  TextEditingController searchController = TextEditingController();

  // void filterProducts(String query) {
  //   final result = productData.where((product) {
  //     final name = product['product_name'].toString().toLowerCase();
  //     final desc = product['product_description'].toString().toLowerCase();
  //     final searchLower = query.toLowerCase();
  //     return name.contains(searchLower) || desc.contains(searchLower);
  //   }).toList();

  //   setState(() {
  //     filteredProducts = result;
  //   });
  // }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  Future<void> loadInitialData() async {
    DialogConstant.loading(context, 'Loading...');
    await getCompan();
    await getProductData();
    await localDataCheck();
    Get.back();
  }

  Future<void> getCompan() async {
    try {
      final response =
          await http.get(Uri.parse('${API.BASE_URL}/api/toko/get_compan'));

      if (response.statusCode == 200) {
        // Mengonversi JSON response menjadi List<Map<String, dynamic>>
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

  Future<void> getProductData() async {
    String compan_code = 'all';

    if (await LocalData.containsKey('compan_code')) {
      compan_code = await LocalData.getData('compan_code');
    }
    final fetchData = await CheckoutsData.getPointData(compan_code);

    setState(() {
      productData = fetchData['productData'].toList();
    });
  }

  Future<void> localDataCheck() async {
    if (await LocalData.containsKey('compan_code')) {
      final compan_code = await LocalData.getData('compan_code');
      setState(() {
        selectedCompanyCode = compan_code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WidgetHelper.appbarWidget(() {
        Get.back();
      }, Text('Redeem'), actions: [
        DropdownButton<String>(
          hint: Text("Pilih Cabang"),
          value: selectedCompanyCode,
          items: companyCode.map((company) {
            return DropdownMenuItem<String>(
              value: company["compan_code"], // Menyimpan company_code
              child: Text(company["name"]!), // Menampilkan name
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCompanyCode = newValue!;
            });
            LocalData.saveData('compan_code', selectedCompanyCode);
            getProductData();
          },
        ),
      ]),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search product...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[700]),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                style: TextStyle(fontSize: 16),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: productRow(searchController.text == ''
                  ? productData
                  : productData.where((product) {
                      final name =
                          product['product_name'].toString().toLowerCase();
                      final desc = product['product_description']
                          .toString()
                          .toLowerCase();
                      final searchLower = searchController.text.toLowerCase();
                      return name.contains(searchLower) ||
                          desc.contains(searchLower);
                    }).toList()),
            ),
          ),
        ],
      ),
    );
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
              isPoint: true));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImageView(
              imagePath:
                  "${API.BASE_URL}/img/gambar_produk_tukar_poin/${product['image_url']}",
              height: 150, // Adjust image height as needed
              width: double.infinity,
              alignment: Alignment.center,
            ),
            SizedBox(height: 12), // Space between image and text
            Text(
              maxLines: 2,
              product['product_name'], // Product name
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Increase font size
                color: Colors.black87, // Darker text color
              ),
            ),
            SizedBox(height: 4), // Space between name and price
            Text(
              'Point: ${currencyFormatter.format(product['price'])}', // Product price
              style: TextStyle(
                fontSize: 16, // Font size for price
                color: Colors.green, // Green color for price
              ),
            ),
            SizedBox(height: 4), // Space between price and quantity
            Text(
              'Quantity: ${product['quantity']}', // Product quantity
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
