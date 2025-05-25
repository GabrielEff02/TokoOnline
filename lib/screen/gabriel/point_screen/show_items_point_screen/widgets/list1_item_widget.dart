import 'dart:convert';

import 'package:project_skripsi/screen/gabriel/point_screen/show_items_point_screen/show_items_point_screen.dart';
import 'package:project_skripsi/screen/gabriel/notifications/item_screen.dart';
import 'package:get/get.dart';

import "../../../core/app_export.dart";
import 'package:intl/intl.dart';

class List1ItemWidget extends StatefulWidget {
  const List1ItemWidget({
    Key? key,
    this.data,
    this.color,
    required this.onQuantityChanged, // Callback to notify quantity changes
  }) : super(key: key);

  final bool? color;
  final Map<String, dynamic>? data;
  final void Function(dynamic updatedData) onQuantityChanged;

  @override
  _List1ItemWidgetState createState() => _List1ItemWidgetState();

  dynamic getData() {
    return data;
  }
}

class _List1ItemWidgetState extends State<List1ItemWidget> {
  late TextEditingController _controller;
  int _quantity = 0;
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 0.toString());
    checkdata();
  }

  void checkdata() async {
    if (await LocalData.containsKey('point_cart')) {
      final datas = jsonDecode(await LocalData.getData('point_cart'));
      final compan = await LocalData.getData('compan_code');
      for (dynamic data in datas[compan]) {
        if (data == widget.data!['product_id'].toString()) {
          setState(() {
            if (_quantity <
                (widget.data!['quantity'] is String
                    ? int.parse(widget.data!['quantity'])
                    : widget.data!['quantity'])) {
              _increment(isChangeLocalData: false);
            } else {
              _decrement();
            }
          });
        }
      }
    }
  }

  void changeLocalData({bool addData = true, int? count}) async {
    final compan = await LocalData.getData('compan_code');
    var cart = jsonDecode(await LocalData.getData('point_cart'));
    List<String> cartData = [];

    if (await LocalData.containsKey('point_cart')) {
      cartData = List<String>.from(cart[compan].map((data) => data.toString()));
    }

    String productId = widget.data!['product_id'].toString();

    if (addData) {
      cartData.add(productId);
    } else {
      cartData.remove(productId);
    }

    int currentCount = cartData.where((item) => item == productId).length;

    if (count != null) {
      if (currentCount > count) {
        int toRemove = currentCount - count;
        cartData.removeWhere((item) {
          if (item == productId && toRemove > 0) {
            toRemove--;
            return true;
          }
          return false;
        });
      } else if (currentCount < count) {
        cartData.addAll(List<String>.filled(count - currentCount, productId));
      } else if (count == 0) {
        cartData.removeWhere((item) => item == productId);
      }
    }
    cart[compan] = cartData;
    LocalData.saveData('point_cart', jsonEncode(cart));
  }

  void _increment({bool isChangeLocalData = true}) {
    if (_quantity <
        (widget.data!['quantity'] is String
            ? int.parse(widget.data!['quantity'])
            : widget.data!['quantity'])) {
      setState(() {
        _quantity++;
        _controller.text = _quantity.toString();
        _notifyQuantityChange();
      });
    }

    if (isChangeLocalData) changeLocalData();
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
        _controller.text = _quantity.toString();
        _notifyQuantityChange();
      });
    }
    changeLocalData(addData: false);
  }

  void _onChanged(String value) {
    _controller.text = (int.parse(_controller.text)).toString();
    int? newValue = int.tryParse(value);
    if (newValue != null) {
      if (newValue < 0) {
        setState(() {
          _quantity = 0;
          _controller.text = _quantity.toString();
        });
      } else if (newValue > widget.data!['quantity']) {
        setState(() {
          _quantity = widget.data!['quantity'];
          _controller.text = _quantity.toString();
        });
      } else {
        setState(() {
          _quantity = newValue;
        });
      }
      changeLocalData(count: (value != null) ? int.parse(value) : null);
      _notifyQuantityChange();
    }
    if (_controller.text.isEmpty) {
      _controller.text = 0.toString();
    }
  }

  void _notifyQuantityChange() {
    widget.data!['quantity_selected'] = _quantity;
    widget.onQuantityChanged(widget.data!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data!['quantity_selected'] != null &&
        widget.data!['quantity_selected'] > 0) {
      ShowItemsPointScreen.countWidget += 1;
      return Container(
        color: widget.color!
            ? const Color.fromARGB(255, 250, 221, 133)
            : Colors.blue[50]!,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(ItemScreen(
                  data: widget.data!.map((key, value) =>
                          MapEntry(key.toString(), value.toString()))
                      as Map<String, dynamic>,
                  isPoint: true,
                ));
              },
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: CustomImageView(
                  imagePath:
                      "${API.BASE_URL}/images/${widget.data!['image_url']}",
                  height: 225.v,
                  alignment: Alignment.center,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 18.v),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data!['product_name'],
                    style: const TextStyle(
                        color: Color.fromARGB(255, 6, 136, 112),
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quantity: ${widget.data!['quantity']}",
                            style: TextStyle(
                                color: !widget.color!
                                    ? const Color.fromARGB(255, 9, 0, 139)
                                    : const Color.fromARGB(255, 162, 7, 7),
                                fontSize: 14),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            "Price: ${currencyFormatter.format(widget.data!['price'])}",
                            style: TextStyle(
                                fontSize: 14,
                                color: widget.color!
                                    ? const Color.fromARGB(255, 9, 0, 139)
                                    : const Color.fromARGB(255, 162, 7, 7)),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius:
                              BorderRadius.all(Radius.circular(6.adaptSize)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              iconSize: 16,
                              onPressed: _decrement,
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: 40, // Mengurangi lebar TextField
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: _controller,
                                keyboardType: TextInputType.number,
                                onChanged: _onChanged,
                                style: const TextStyle(
                                    fontSize: 14), // Mengurangi ukuran teks
                                decoration: const InputDecoration(
                                  border: InputBorder
                                      .none, // Menghilangkan garis di bawah TextField
                                  isDense: true, // Mengurangi padding TextField
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              iconSize: 16, // Mengurangi ukuran ikon
                              onPressed: _increment,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }
}
