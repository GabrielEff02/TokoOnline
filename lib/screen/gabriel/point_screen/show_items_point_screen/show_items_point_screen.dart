import 'dart:convert';

import 'package:project_skripsi/constant/dialog_constant.dart';
import 'package:project_skripsi/screen/gabriel/point_screen/show_items_point_screen/widgets/list1_item_widget.dart';
import 'package:project_skripsi/screen/home/landing_home.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../core/app_export.dart';
import 'package:http/http.dart' as http;

class ShowItemsPointScreen extends StatefulWidget {
  static int countWidget = 0;

  @override
  _ShowItemsPointScreenState createState() => _ShowItemsPointScreenState();
}

class _ShowItemsPointScreenState extends State<ShowItemsPointScreen> {
  List<dynamic> displayedItems = [];
  List<dynamic> selectedItems = [];
  List<Map<String, dynamic>> companyCode = [];
  late var productData;
  int totalPrice = 0;
  bool isLoading = false;
  String name = '';
  int point = 0;
  String selectedCompanyCode = 'semua';
  bool checkCompan = false;
  bool checkProduct = false;
  String truncateText(String text, {int maxLength = 15}) {
    return text.length > maxLength
        ? "${text.substring(0, maxLength)}..."
        : text;
  }

  Future<void> checkingCompan() async {
    DialogConstant.loading(context, 'Loading...');

    if (await LocalData.containsKey('compan_code')) {
      final companyCode = await LocalData.getData('compan_code');
      setState(() {
        checkCompan = true;
        selectedCompanyCode = companyCode;
      });
      await _sortInitialData();
    }
    Get.back();
  }

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
    await getFullName();
    await checkingCompan();
    Get.back();
  }

  Future<void> getCompan() async {
    try {
      final response =
          await http.get(Uri.parse('${API.BASE_URL}/get_compan.php'));

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

  Future<void> getFullName() async {
    final names = await LocalData.getData("full_name");
    final points = await LocalData.getData('point');

    setState(() {
      name = names;
      point = int.parse(points);
    });
  }

  Future<void> _sortInitialData() async {
    selectedItems = [];
    if (await LocalData.containsKey('point_cart')) {
      final datas = jsonDecode(await LocalData.getData('point_cart'));
      final compan = await LocalData.getData('compan_code');
      final listData = await CheckoutsData.getPointData(compan);

      productData = listData['productData'];

      if (datas.keys.contains(compan)) {
        List<int> uniquePriorityOrder = [];
        for (String data in datas[compan]) {
          if (!uniquePriorityOrder.contains(int.parse(data))) {
            uniquePriorityOrder.add(int.parse(data));
          }
        }
        uniquePriorityOrder.sort();
        setState(() {
          checkProduct = true;
          selectedItems = [];

          productData.sort((a, b) {
            int productIdA = a["product_id"] as int;
            int productIdB = b["product_id"] as int;

            int indexA = uniquePriorityOrder.indexOf(productIdA);
            int indexB = uniquePriorityOrder.indexOf(productIdB);

            if (indexA == -1) indexA = 9999;
            if (indexB == -1) indexB = 9999;

            return indexA.compareTo(indexB);
          });

          displayedItems = productData.toList();
        });
      } else {
        setState(() {
          checkProduct = false;
          displayedItems = productData.toList();
        });
      }
    }
  }

  void _onQuantityChanged(dynamic updatedData) {
    setState(() {
      int index = displayedItems.indexWhere(
          (item) => (item['product_id']) == updatedData['product_id']);
      if (index != -1) {
        displayedItems[index] = updatedData;
      }
      if (updatedData['quantity'] is! int) {
        updatedData['quantity'] = int.parse(updatedData['quantity']);
      }

      if (updatedData['quantity'] > 0) {
        selectedItems.removeWhere(
            (item) => item['product_id'] == updatedData['product_id']);
        selectedItems.add(updatedData);
      } else {
        selectedItems.removeWhere(
            (item) => item['product_id'] == updatedData['product_id']);
      }
      totalPrice = selectedItems.fold(
          0,
          (sum, item) =>
              sum +
              (int.tryParse(item['price'].toString()) ?? 0) *
                  (int.tryParse(item['quantity_selected'].toString()) ?? 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    bool color = true;
    return Scaffold(
      backgroundColor: appTheme.whiteA700,
      appBar: WidgetHelper.appbarWidget(
          () => Get.offAll(LandingHome()),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Hello $name!!!", style: CustomTextStyle.titleSmallBlack900),
            Text(
              'Points!!: ${currencyFormatter.format(point)}',
              style: CustomTextStyle.titleSmallBlack900,
            )
          ]),
          actions: [
            DropdownButton<String>(
              hint: Text("Pilih Perusahaan"),
              value: selectedCompanyCode,
              items: companyCode.map((company) {
                return DropdownMenuItem<String>(
                  value: company["compan_code"], // Menyimpan company_code
                  child: Text(
                    truncateText(company["name"]!),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCompanyCode = newValue!;
                });
                LocalData.saveData('compan_code', selectedCompanyCode);
                checkingCompan();
              },
            )
          ]),
      body: checkCompan
          ? checkProduct
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayedItems.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == displayedItems.length) {
                            return Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          var widgetData = displayedItems[index];

                          return List1ItemWidget(
                            key: ValueKey(widgetData['product_id']),
                            data: widgetData,
                            color: color = !color,
                            onQuantityChanged: _onQuantityChanged,
                          );
                        },
                      ),
                    ),
                    if (totalPrice > 0)
                      Container(
                          color: Colors.transparent, height: 75.adaptSize),
                  ],
                )
              : Center(
                  child: Text('Tidak ada produk yang dipilih',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w900)),
                )
          : Center(
              child: Text('Harap memilih cabang terlebih dahulu',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w900)),
            ),
      bottomSheet: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        height: totalPrice > 0 ? 75.adaptSize : 0,
        child: totalPrice > 0
            ? Padding(
                padding: EdgeInsets.all(10.adaptSize),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.h),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Total Price: ",
                                style: CustomTextStyle.bodyMediumBlueGray600),
                            TextSpan(
                              text: currencyFormatter.format(totalPrice),
                              style: point < totalPrice
                                  ? CustomTextStyle.bodyLargeRed700
                                  : CustomTextStyle.bodyLargeGreen700,
                            ),
                          ],
                        ),
                      ),
                    ),
                    (point >= totalPrice)
                        ? Padding(
                            padding: EdgeInsets.only(right: 15.h),
                            child: IconButton(
                              icon: Icon(Icons.shopping_cart,
                                  color: appTheme.black900),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.pointCartScreen,
                                  arguments: selectedItems,
                                );
                              },
                            ),
                          )
                        : Text('Point tidak mencukupi',
                            style: CustomTextStyle.bodyLargeRed700),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
