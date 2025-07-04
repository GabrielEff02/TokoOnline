import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_skripsi/screen/auth/second_splash.dart';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';

class ShoppingCartController {
  Future<void> postTransactions({
    List<dynamic>? postTransactionDetail,
    num? totalAmount,
    String? alamat,
    bool? isDelivery,
    void Function(dynamic result, dynamic exception)? callback,
  }) async {
    final header = {'Content-Type': 'application/json'};
    final username = await LocalData.getData("user");
    final companCode = await LocalData.getData("compan_code");
    final email = await LocalData.getData("email");
    final phone = await LocalData.getData("phone");

    final items = postTransactionDetail!.map((transaction) {
      return {
        'product_id': transaction['brg_id'],
        'quantity': transaction['quantity_selected'],
        'total_price': transaction['harga'] * transaction['quantity_selected'],
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

    LocalData.saveData("pending_transaction", jsonEncode(postData));

    final orderRequest = {
      'amount': totalAmount,
      'name': username,
      'email': email,
      'phone': phone,
    };

    API.basePost('/api/toko/create_transaction', orderRequest, header, true,
        (result, error) async {
      if (error != null) {
        callback?.call(null, error);
        return;
      }

      final snapToken = result['data']['snap_token'];
      final snapUrl =
          'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';

      await launchUrl(Uri.parse(snapUrl), mode: LaunchMode.externalApplication);
    });
  }

  Future<void> submitPendingTransaction() async {
    final postDataJson = await LocalData.getData("pending_transaction");
    if (postDataJson == null) return;

    final postData = jsonDecode(postDataJson);
    final companCode = postData['compan_code'];
    final header = {'Content-Type': 'application/json'};

    API.basePost('/api/toko/update_transaction', postData, header, true,
        (result, error) async {
      print(result);
      print(error);
      if (error == null) {
        final cart = jsonDecode(await LocalData.getData('cart'));
        cart.remove(companCode);
        LocalData.saveData('cart', jsonEncode(cart));
        Get.back();
        DialogConstant.alert('Transaksi Berhasil...');
        Get.to(SecondSplash());
      }
    });

    await LocalData.removeData("pending_transaction");
  }
}
