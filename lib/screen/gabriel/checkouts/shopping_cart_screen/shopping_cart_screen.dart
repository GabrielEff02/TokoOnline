import 'dart:convert';

import 'package:project_skripsi/screen/navbar_menu/alamat_screen.dart';

import '../../checkouts/shopping_cart_screen/shopping_cart_controller/shopping_cart_controller.dart';
import '../../core/app_export.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key, required this.items}) : super(key: key);

  final List<dynamic> items;

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  late num totalQuantityFinal = 0;
  late num totalPriceFinal = 0;
  String namaCabang = '';
  bool isChecked = false;
  late List<Alamat> alamatList;
  Alamat? selectedAlamat;
  late num deliveryPrice = 0;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
    super.initState();
  }

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  Future<void> loadInitialData() async {
    DialogConstant.loading(context, 'Loading...');
    await getCompanName();
    await fetchAlamatList();
    Get.back();
  }

  Future<void> getCompanName() async {
    final compan = await LocalData.getData('compan_code');
    try {
      final response =
          await http.get(Uri.parse('${API.BASE_URL}/api/toko/get_compan'));
      if (response.statusCode == 200) {
        // Mengonversi JSON response menjadi List<Map<String, dynamic>>
        List<dynamic> jsonData = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: CustomTextStyle.titleLargeBlack900,
        ),
        actions: [
          IconButton(
              onPressed: () {
                showAreYouSureDialog(
                    context,
                    () => submitItems(
                        widget.items,
                        totalPriceFinal + deliveryPrice,
                        isChecked,
                        isChecked ? selectedAlamat!.alamat : ''));
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
            if (isChecked)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: buildAlamatDropdown(),
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.adaptSize),
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

  void submitItems(
      items, num totalPriceFinal, bool isCheked, String alamat) async {
    if (items.toString().isNotEmpty) {
      DialogConstant.loading(context, 'Transaction on Process...');

      ShoppingCartController().postTransactions(
          totalAmount: totalPriceFinal,
          alamat: alamat,
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
  }

  Widget _buildStickyBottomSection(BuildContext context) {
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
            padding: EdgeInsets.all(20.adaptSize),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Item Price:',
                        style: CustomTextStyle.titleMediumBlack900),
                    Text(currencyFormatter.format(totalPriceFinal),
                        style: CustomTextStyle.titleMediumBlack900)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Apakah pesanan anda ingin dikirim?",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w900),
                    ),
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? newValue) {
                        if (newValue == true) {
                          if (alamatList.isEmpty) {
                            showAddressNotFoundDialog(
                                context, () => Get.to(AlamatScreen()));
                          } else {
                            _showDeliveryConfirmation();
                          }
                        } else {
                          setState(() {
                            isChecked = newValue ?? false;
                          });
                        }
                      },
                      activeColor: Colors.blue, // Warna saat checkbox dipilih
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Price:',
                        style: CustomTextStyle.titleMediumBlack900),
                    Text(
                      currencyFormatter.format(totalPriceFinal + deliveryPrice),
                      style: CustomTextStyle.titleMediumBlack900,
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

  void showAddressNotFoundDialog(
      BuildContext context, VoidCallback onRegisterAddress) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan info icon
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.amber.shade400,
                        Colors.orange.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Info icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_off_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Alamat Tidak Ditemukan',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Address icon
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.home_outlined,
                          size: 24,
                          color: Colors.orange.shade600,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Pesan utama
                      Text(
                        'Mohon Maaf',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Anda tidak memiliki alamat yang sudah terdaftar. Silakan daftarkan alamat terlebih dahulu untuk melanjutkan proses ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          // Tombol Cancel
                          Expanded(
                            child: Container(
                              height: 45,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cancel_outlined,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Batal',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Tombol Daftar Alamat
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onRegisterAddress();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_location_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Daftar Alamat',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeliveryConfirmation() {
    DateTime now = DateTime.now().toUtc().add(Duration(hours: 8));
    String _formatDate(DateTime date) {
      List<String> days = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu'
      ];
      List<String> months = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];

      String dayName = days[date.weekday % 7];
      String monthName = months[date.month];

      return '$dayName, ${date.day} $monthName ${date.year}';
    }

    // Menentukan waktu pengiriman
    String deliveryMessage;
    if (now.hour >= 12) {
      DateTime tomorrow = now.add(Duration(days: 1));
      deliveryMessage =
          "Pesanan akan dikirim besok (${_formatDate(tomorrow)}) pada jam 13:00 WIB";
    } else {
      // Jika sebelum jam 12 siang, kirim hari ini jam 1 siang
      deliveryMessage =
          "Pesanan akan dikirim hari ini (${_formatDate(now)}) pada jam 13:00 WIB";
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan icon dan background gradient
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Icon pengiriman
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_shipping,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Konfirmasi Pengiriman',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.schedule,
                          size: 24,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Icon waktu
                      Text(
                        'Pesanan akan dikenakan biaya kirim sebesar: 10% atau Rp. ${currencyFormatter.format(deliveryPrice)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Pesan konfirmasi
                      Text(
                        deliveryMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          // Tombol Batal
                          Expanded(
                            child: Container(
                              height: 45,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Batal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Tombol Konfirmasi
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    isChecked = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Konfirmasi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

    items.sort((a, b) => a['brg_id'].compareTo(b['brg_id']));
    List<Map<String, dynamic>> filteredItems = items
        .where((item) =>
            item['quantity_selected'] > 0) // Filter where quantity > 0
        .map((item) {
      return {
        'image': "${API.BASE_URL}/img/gambar_produk/${item['url']}",
        'product': item['nama'],
        'product description': item['deskripsi'],
        'quantity': item['quantity_selected'],
        'price': item['harga'],
        'total price': item['harga'] * item['quantity_selected']
      };
    }).toList();

    if (filteredItems.isNotEmpty) {
      List<Widget> cards = filteredItems.map((product) {
        setState(() {
          // Update total quantities and prices in setState
          totalQuantityFinal += product['quantity'];
          totalPriceFinal += product['total price'];
          if (isChecked) {
            if (deliveryPrice + (product['total price'] * .1) < 10000) {
              deliveryPrice += (product['total price'] * .1);
            } else {
              deliveryPrice = 10000;
            }
          } else {
            deliveryPrice = 0;
          }
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
        arguments: AppRoutes.shoppingCartScreen,
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan warning icon
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange.shade400,
                        Colors.red.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Warning icon dengan animasi
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Konfirmasi Transaksi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Question mark icon
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.help_outline,
                          size: 24,
                          color: Colors.orange.shade600,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Pesan konfirmasi
                      Text(
                        'Apakah Anda yakin?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Apakah Anda yakin ingin melanjutkan transaksi ini? Pastikan semua data sudah benar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          // Tombol Cancel
                          Expanded(
                            child: Container(
                              height: 45,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Batal',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Tombol Ya/Konfirmasi
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF46F2D8), // Sesuai warna asli
                                    Color(0xFF2DD4BF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF46F2D8).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onConfirm();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Ya',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
