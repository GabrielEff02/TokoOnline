import 'dart:convert';

import 'package:project_skripsi/screen/auth/second_splash.dart';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';

class PointCartController {
  Future<void> postTransactions(
      {BuildContext? context,
      void callback(result, exception)?,
      List<dynamic>? postTransactionDetail,
      num? totalAmount,
      String? alamat,
      bool? isDelivery}) async {
    var header = <String, String>{};

    header['Content-Type'] = 'application/json';
    String username = await LocalData.getData("user");
    final companCode = await LocalData.getData('compan_code');
    final items = postTransactionDetail!.map((transaction) {
      return {
        'product_id': transaction['product_id'],
        'quantity': transaction['quantity_selected'],
        'total_price': transaction['price'] * transaction['quantity_selected'],
      };
    }).toList();

    final postData = {
      'compan_code': companCode,
      'alamat': isDelivery! ? alamat : '',
      'username': username,
      'total_amount': totalAmount,
      'is_delivery': isDelivery,
      'items': items,
    };

    API.basePost('/api/toko/update_point_transaction', postData, header, true,
        (result, error) async {
      if (error != null) {
        callback?.call(null, error);
      } else {
        LocalData.saveData('point',
            '${int.parse(await LocalData.getData('point')) - totalAmount!}');
        final cart = jsonDecode(await LocalData.getData('point_cart'));
        cart.remove(companCode);
        LocalData.saveData('point_cart', jsonEncode(cart));
        Get.back();
        Get.to(SecondSplash());
        callback?.call(result, null);
      }
    });
  }
}
