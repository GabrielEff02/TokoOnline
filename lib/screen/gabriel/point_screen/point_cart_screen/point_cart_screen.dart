import 'dart:convert';

import 'package:project_skripsi/screen/gabriel/point_screen/point_cart_screen/point_cart_controller/point_cart_controller.dart';
import 'package:project_skripsi/screen/gabriel/request_item/request_history_screen/request_history_screen.dart';
import 'package:project_skripsi/screen/home/landing_home.dart';
import 'package:project_skripsi/screen/navbar_menu/alamat_screen.dart';
import 'package:project_skripsi/screen/ocr_ktp/view/home.dart';
import 'package:get/get.dart';

import '../../checkouts/shopping_cart_screen/shopping_cart_controller/shopping_cart_controller.dart';
import '../../../../constant/dialog_constant.dart';
import '../../core/app_export.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class PointCartScreen extends StatefulWidget {
  const PointCartScreen(
      {super.key,
      required this.items,
      this.requestItem = false,
      this.callback});
  final Function(dynamic, dynamic)? callback;
  final bool requestItem;
  final List<dynamic> items;

  @override
  _PointCartScreenState createState() => _PointCartScreenState();
}

class _PointCartScreenState extends State<PointCartScreen> {
  late num totalQuantityFinal = 0;
  late num totalPriceFinal = 0;
  late int point;
  String namaCabang = '';
  bool isChecked = false;
  late List<Alamat> alamatList;
  Alamat? selectedAlamat;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
    super.initState();
  }

  Future<void> loadInitialData() async {
    DialogConstant.loading(context, 'Loading...');
    await getPoint();
    await getCompanName();
    await fetchAlamatList();
    Get.back();
  }

  Future<void> fetchAlamatList() async {
    final username = await LocalData.getData('user');
    final response = await http.get(
        Uri.parse('${API.BASE_URL}/api/toko/getAlamat?username=$username'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        alamatList = data.map((e) => Alamat.fromJson(e)).toList();
        if (alamatList.isNotEmpty) {
          selectedAlamat = alamatList.firstWhere((a) => a.isPrimary,
              orElse: () => alamatList.first);
        }
      });
    } else {
      alamatList = [];
    }
  }

  Future<void> getPoint() async {
    final points = await LocalData.getData('point');
    setState(() {
      point = int.parse(points);
    });
  }

  Future<void> getCompanName() async {
    final compan = await LocalData.getData('compan_code');
    try {
      final response =
          await http.get(Uri.parse('${API.BASE_URL}/api/toko/get_compan'));
      if (response.statusCode == 200) {
        // Mengonversi JSON response menjadi List<Map<String, dynamic>>
        List<dynamic> jsonData = json.decode(response.body);
        print(jsonData
            .firstWhere((companies) => companies['compan_code'] == compan));
        setState(() {
          namaCabang = jsonData.firstWhere(
              (companies) => companies['compan_code'] == compan)['name'];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Widget buildAlamatDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Alamat>(
          value: selectedAlamat,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(color: Colors.black, fontSize: 14),
          onChanged: (Alamat? newValue) {
            setState(() {
              selectedAlamat = newValue!;
            });
          },
          items: alamatList.map((alamat) {
            return DropdownMenuItem<Alamat>(
              value: alamat,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      alamat.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Text(
                      alamat.alamat,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${alamat.kota}, ${alamat.provinsi}, ${alamat.kodePos}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const Divider(height: 10),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Point Cart",
          style: CustomTextStyle.titleLargeBlack900,
        ),
        actions: [
          IconButton(
              onPressed: () {
                showAreYouSureDialog(
                    context,
                    () => (widget.requestItem)
                        ? submitItems(
                            widget.items,
                            totalPriceFinal,
                            isChecked,
                            isChecked ? selectedAlamat!.alamat : '',
                            widget.requestItem,
                            callback: widget.callback)
                        : submitItems(
                            widget.items,
                            totalPriceFinal,
                            isChecked,
                            isChecked ? selectedAlamat!.alamat : '',
                            widget.requestItem));
              },
              icon: Icon(
                Icons.check,
                weight: 20.adaptSize,
                color: appTheme.green700,
              ))
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.v, vertical: 10.v),
        child: Column(
          children: [
            if (isChecked) buildAlamatDropdown(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                namaCabang,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: appTheme.gray30099,
                    borderRadius: BorderRadius.all(Radius.circular(10.h)),
                  ),
                  child: _showProductCards(context, widget.items)),
            ),
            _buildStickyBottomSection(context),
          ],
        ),
      ),
    );
  }

  void submitItems(
      items, totalPriceFinal, isCheked, String alamat, bool requestItem,
      {void Function(dynamic, dynamic)? callback}) async {
    if (items.toString().isNotEmpty) {
      DialogConstant.loading(context, 'Transaction on Process...');

      if (await LocalData.containsKey('detailKTP')) {
        if (requestItem) {
          print(items);
          API.basePost(
              '/api/toko/approve_request',
              {
                'request_id': items[0]['request_id'],
                'username': await LocalData.getData('user')
              },
              {'Content-Type': 'application/json'},
              true, (result, error) async {
            Get.offAll(RequestHistoryScreen());
            callback?.call(result, null);
          });
        } else {
          PointCartController().postTransactions(
              alamat: alamat,
              totalAmount: totalPriceFinal,
              isDelivery: isCheked,
              context: context,
              callback: (result, error) {
                if (result != null && result['error'] != true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color.fromARGB(88, 0, 0, 0),
                      content: Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Transaction Success!!!',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  DialogConstant.alert(error.toString());
                }
                ;
              },
              postTransactionDetail: items);
        }
      } else {
        Get.to(KtpOCR(postDetail: items));
      }
    }
  }

  Widget _buildStickyBottomSection(BuildContext context) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return Column(
      children: [
        // Card(
        //   margin: const EdgeInsets.symmetric(vertical: 8.0),
        //   child: Padding(
        //     padding: const EdgeInsets.all(16.0),
        //     child:
        //   ),
        // ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Point:',
                    style: CustomTextStyle.titleMediumBlack900),
                Text(currencyFormatter.format(totalPriceFinal),
                    style: CustomTextStyle.titleMediumRed700)
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance:', style: CustomTextStyle.titleMediumBlack900),
                Text(
                  currencyFormatter.format(point),
                  style: CustomTextStyle.titleMediumBlack900,
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? newValue) {
                        setState(() {
                          isChecked = newValue ?? false;
                        });
                      },
                      activeColor: Colors.blue, // Warna saat checkbox dipilih
                    ),
                    Text(
                      "Apakah pesanan anda ingin dikirim?",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Remain Balance:',
                        style: CustomTextStyle.titleMediumBlack900),
                    Text(
                      currencyFormatter.format(point - totalPriceFinal),
                      style: CustomTextStyle.titleMediumGreen700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _showProductCards(BuildContext context, List<dynamic> items) {
    totalQuantityFinal = 0;
    totalPriceFinal = 0;
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    items.sort((a, b) => a['product_id'].compareTo(b['product_id']));
    List<Map<String, dynamic>> filteredItems = items
        .where((item) =>
            item['quantity_selected'] > 0) // Filter where quantity > 0
        .map((item) {
      return {
        'image':
            "${API.BASE_URL}/img/gambar_produk_tukar_poin/${item['image_url']}",
        'product': item['product_name'],
        'product description': item['product_description'],
        'quantity': item['quantity_selected'],
        'price': item['price'],
        'total price': item['price'] * item['quantity_selected']
      };
    }).toList();

    if (filteredItems.isNotEmpty) {
      List<Widget> cards = filteredItems.map((product) {
        setState(() {
          // Update total quantities and prices in setState
          totalQuantityFinal += product['quantity'];
          totalPriceFinal += product['total price'];
        });

        // Return product card widget
        return _cardProductWidget(product, currencyFormatter);
      }).toList();

      // Return ListView with the cards as children
      return ListView(children: cards);
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.notFoundScreen,
        arguments: AppRoutes.pointCartScreen,
      );
      return Container();
    }
  }

  Widget _cardProductWidget(
      Map<String, dynamic> product, NumberFormat currencyFormatter) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!widget.requestItem)
              Image.network(
                product['image'],
                width: 50,
                height: 50,
              ),
            SizedBox(width: 5.adaptSize),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      product['product'],
                      style: CustomTextStyle.titleSmallBlack900,
                    ),
                  ),
                  SizedBox(height: 3.adaptSize),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "\tprice: ${product['price']}",
                      style: CustomTextStyle.bodySmallBlack900,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "\tqty: ${product['quantity'].toString()}",
                      style: CustomTextStyle.bodySmallBlack900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.adaptSize),
            Text(
              currencyFormatter.format(product['total price']),
              style: CustomTextStyle.titleMediumBlack900,
            ),
          ],
        ),
      ),
    );
  }

  void showAreYouSureDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text("Are you sure?"),
            ],
          ),
          content: Text("Are you sure you want to proceed with this action?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Call the confirmation action
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 70, 242, 216)),
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
