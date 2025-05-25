import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_skripsi/constant/dialog_constant.dart';
import 'package:project_skripsi/screen/gabriel/notifications/item_screen.dart';
import '../../../screen/gabriel/core/app_export.dart';

class SearchProductScreen extends StatefulWidget {
  const SearchProductScreen({Key? key}) : super(key: key);

  @override
  _SearchProductScreenState createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<SearchProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  bool _isFocused = false;
  List<dynamic> productData = [];
  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final data = await LocalData.getData('search_history');
    if (data != null && data.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        _recentSearches = List<String>.from(decoded.reversed.take(5));
      });
    }
  }

  Future<void> _saveSearch(String query) async {
    final data = await LocalData.getData('search_history');
    List<String> currentHistory = data != null && data.isNotEmpty
        ? List<String>.from(jsonDecode(data))
        : [];

    if (query.trim().isEmpty) return;

    // Hindari duplikasi
    currentHistory.remove(query);
    currentHistory.add(query);

    final encoded = jsonEncode(currentHistory);
    LocalData.saveData('search_history', encoded);
    _loadSearchHistory();
  }

  Future<void> _deleteSearch(String item) async {
    final data = await LocalData.getData('search_history');
    List<String> currentHistory = data != null && data.isNotEmpty
        ? List<String>.from(jsonDecode(data))
        : [];

    currentHistory.remove(item);
    final encoded = jsonEncode(currentHistory);
    LocalData.saveData('search_history', encoded);
    _loadSearchHistory();
  }

  Future<void> loadData() async {
    DialogConstant.loading(context, 'Loading...');

    await getProductData();

    Get.back();
    await Future.delayed(Duration(milliseconds: 100));
    FocusScope.of(context).unfocus();
    setState(() {
      _isFocused = false;
    });
  }

  Future<void> getProductData() async {
    String compan_code = 'all';

    if (await LocalData.containsKey('compan_code')) {
      compan_code = await LocalData.getData('compan_code');
    }
    final fetchData = await CheckoutsData.getInitData(compan_code);

    setState(() {
      productData = fetchData['productData'].toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25.adaptSize),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  _isFocused = hasFocus;
                });
              },
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _saveSearch(value);
                  loadData();
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cari produk...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _saveSearch(_searchController.text);
                      loadData();
                    },
                  ),
                ),
              )),
          if (_isFocused && _recentSearches.isNotEmpty) ...[
            Expanded(
              child: ListView.builder(
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  final item = _recentSearches[index];
                  return ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.watch_later_outlined),
                        SizedBox(
                          width: 20.h,
                        ),
                        Text(item.toLowerCase()),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _deleteSearch(item),
                    ),
                    onTap: () {
                      _searchController.text = item;
                      _saveSearch(item);
                      loadData();
                      print(_isFocused);
                    },
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          _searchController.text != '' && !_isFocused
              ? Expanded(
                  child: ListView(
                    children: productRow(productData.where((product) {
                      final name = product['brg_name'].toString().toLowerCase();
                      final desc =
                          product['brg_deskripsi'].toString().toLowerCase();
                      final searchLower = _searchController.text.toLowerCase();
                      return name.contains(searchLower) ||
                          desc.contains(searchLower);
                    }).toList()),
                  ),
                )
              : Container(),
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
