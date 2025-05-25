import 'package:project_skripsi/screen/auth/second_splash.dart';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';
import 'package:get/get.dart';

class ShoppingCartController {
  Future<void> postTransactions(
      {BuildContext? context,
      void callback(result, exception)?,
      Map<String, dynamic>? postTransaction,
      List<dynamic>? postTransactionDetail}) async {
    var header = <String, String>{};

    header['Content-Type'] = 'application/json';
    String username = await LocalData.getData("user");
    final companCode = await LocalData.getData('compan_code');
    postTransaction!['username'] = username;
    API.basePost('/update_transaction.php', postTransaction, header, true,
        (result, error) {
      for (dynamic transaction in postTransactionDetail!) {
        final postDetail = {
          'username': username,
          'product_id': transaction['product_id'],
          'quantity': transaction['quantity_selected'],
          'total_price':
              transaction['price'] * transaction['quantity_selected'],
          'compan_code': companCode
        };
        API.basePost('/update_transaction_detail.php', postDetail, header, true,
            (result, error) async {
          if (error != null) {
            callback!(null, error);
          } else {
            LocalData.saveData('point',
                '${int.parse(await LocalData.getData('point')) - (transaction['price'] * transaction['quantity_selected'])}');
            LocalData.removeData('cart');
          }
        });
      }
      Future.delayed(Duration(seconds: 4), () {
        Get.back();
        Get.to(SecondSplash());
        if (error != null) {
          callback!(null, error);
        }
        if (result != null) {
          callback!(result, null);
        }
      });
    });
  }
}
