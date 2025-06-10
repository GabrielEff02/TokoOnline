import 'dart:convert';

import 'package:project_skripsi/constant/dialog_constant.dart';
import 'package:project_skripsi/screen/gabriel/checkouts/show_items_screen/widgets/list1_item_widget.dart';
import 'package:project_skripsi/screen/home/landing_home.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../core/app_export.dart';
import 'package:http/http.dart' as http;

class ShowItemsScreen extends StatefulWidget {
  static int countWidget = 0;

  @override
  _ShowItemsScreenState createState() => _ShowItemsScreenState();
}

class _ShowItemsScreenState extends State<ShowItemsScreen> {
  List<dynamic> displayedItems = [];
  Map<String, dynamic> displayedSemua = {};
  List<dynamic> selectedItems = [];
  List<Map<String, dynamic>> companyCode = [];
  late var productData;
  int totalPrice = 0;
  bool isLoading = false;
  String name = '';
  String selectedCompanyCode = 'semua';
  bool checkCompan = false;
  bool checkProduct = false;

  Future<void> checkingCompan() async {
    if (await LocalData.containsKey('compan_code')) {
      final companyCode = await LocalData.getData('compan_code');
      setState(() {
        selectedCompanyCode = companyCode;
      });
    }
    if (selectedCompanyCode.isNotEmpty) {
      checkCompan = true;
      await loadInitialData();
    }
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
    await _sortInitialData();
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

  Future<void> getFullName() async {
    final names = await LocalData.getData("full_name");

    setState(() {
      name = names;
    });
  }

  Future<void> _sortInitialData() async {
    selectedItems = [];
    if (await LocalData.containsKey('cart')) {
      final datas = jsonDecode(await LocalData.getData('cart'));
      final compan = await LocalData.getData('compan_code');
      final listData = await CheckoutsData.getInitData(compan);
      productData = listData['productData'];

      if (datas.keys.contains(compan)) {
        List<int> uniquePriorityOrder = [];
        for (String data in datas[compan]) {
          if (!uniquePriorityOrder.contains(int.parse(data))) {
            uniquePriorityOrder.add(int.parse(data));
          }
        }
        setState(() {
          checkProduct = true;
          selectedItems = [];

          productData.sort((a, b) {
            int productIdA = a["brg_id"] as int;
            int productIdB = b["brg_id"] as int;

            int indexA = uniquePriorityOrder.indexOf(productIdA);
            int indexB = uniquePriorityOrder.indexOf(productIdB);

            if (indexA == -1) indexA = 9999;
            if (indexB == -1) indexB = 9999;

            return indexA.compareTo(indexB);
          });

          displayedItems = productData.toList();
        });
      } else if (compan == 'semua' || compan.isEmpty) {
        for (String companKey in datas.keys) {
          final listData = await CheckoutsData.getInitData(companKey);
          productData = listData['productData'];
          List<int> uniquePriorityOrder = [];
          for (String data in datas[companKey]) {
            if (!uniquePriorityOrder.contains(int.parse(data))) {
              uniquePriorityOrder.add(int.parse(data));
            }
          }
          uniquePriorityOrder.sort();
          setState(() {
            displayedSemua[companKey] = productData
                .where((product) =>
                    uniquePriorityOrder.contains(product['brg_id']))
                .toList();
          });
        }
        checkProduct = true;
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
      int index = displayedItems
          .indexWhere((item) => (item['brg_id']) == updatedData['brg_id']);
      if (index != -1) {
        displayedItems[index] = updatedData;
      }
      if (!(updatedData['quantity'] is int)) {
        updatedData['quantity'] = int.parse(updatedData['quantity']);
      }

      if (updatedData['quantity'] > 0) {
        selectedItems
            .removeWhere((item) => item['brg_id'] == updatedData['brg_id']);
        selectedItems.add(updatedData);
      } else {
        selectedItems
            .removeWhere((item) => item['brg_id'] == updatedData['brg_id']);
      }
      totalPrice = selectedItems.fold(
          0,
          (sum, item) =>
              sum +
              (int.tryParse(item['harga'].toString()) ?? 0) *
                  (int.tryParse(item['quantity_selected'].toString()) ?? 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    bool color = true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4F46E5),
                    const Color(0xFF7C3AED),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Get.offAll(LandingHome()),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Selamat datang,",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                "Hello $name!!!",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Company Dropdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF4F46E5).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.business,
                                  color: Color(0xFF4F46E5),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Pilih Perusahaan",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          value: selectedCompanyCode,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF4F46E5),
                          ),
                          isExpanded: true,
                          items: companyCode.map((company) {
                            return DropdownMenuItem<String>(
                              value: company["compan_code"],
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.domain,
                                      color: Color(0xFF10B981),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      company["name"]!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCompanyCode = newValue!;
                            });
                            LocalData.saveData(
                                'compan_code', selectedCompanyCode);
                            checkingCompan();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: checkProduct
                  ? checkCompan
                      ? Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              // Products Header

                              const SizedBox(height: 15),

                              // Products List
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: displayedItems.length +
                                      (isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == displayedItems.length) {
                                      return Container(
                                        margin: const EdgeInsets.all(20),
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child:
                                                const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Color(0xFF4F46E5),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    var widgetData = displayedItems[index];

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      child: List1ItemWidget(
                                        key: ValueKey(widgetData['brg_id']),
                                        data: widgetData,
                                        color: color = !color,
                                        onQuantityChanged: _onQuantityChanged,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (totalPrice > 0) const SizedBox(height: 100),
                            ],
                          ),
                        )
                      : _semuaCabang(color)
                  : Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFEF4444).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Anda Belum Memiliki Keranjang di Cabang Ini',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),

      // Floating Bottom Sheet
      bottomSheet: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        height: totalPrice > 0 ? 100 : 0,
        child: totalPrice > 0
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFF8FAFC),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: checkProduct
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Total Pembelian",
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp. ${currencyFormatter.format(totalPrice)}',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF4F46E5),
                                    Color(0xFF7C3AED),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5)
                                        .withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.shoppingCartScreen,
                                      arguments: selectedItems,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.shopping_cart_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Keranjang",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Mohon Maaf Harap memilih Cabang terlebih dahulu',
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _semuaCabang(bool color) {
    return ListView(
      children: [
        for (String i in displayedSemua.keys) ...[
          Container(
            padding: EdgeInsets.all(20.adaptSize),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24.adaptSize,
                ),
                SizedBox(width: 12.adaptSize),
                Expanded(
                  child: Text(
                    companyCode.firstWhere(
                      (item) => item['compan_code'] == i,
                      orElse: () => {'name': 'Unknown'},
                    )['name'],
                    style: CustomTextStyle.titleSmallWhiteA700Bold.copyWith(
                      fontSize: 16.adaptSize,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (dynamic j in displayedSemua[i])
            List1ItemWidget(
              key: ValueKey("$i${j['brg_id']}"),
              data: j,
              companCode: i,
              color: color = !color,
              onQuantityChanged: _onQuantityChanged,
            ),
        ],
        if (totalPrice > 0)
          Container(color: Colors.transparent, height: 75.adaptSize),
      ],
    );
  }
}
