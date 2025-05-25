import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api.dart';
import '../constant/dialog_constant.dart';

class EditProfileController extends GetxController {
  postEditProfile(
      {BuildContext? context,
      void callback(result, exception)?,
      Map<String, dynamic>? post}) {
    var header = <String, String>{};

    header['Content-Type'] = 'application/json';
    DialogConstant.loading(context!, 'Loading...');
    API.basePost('/update_user.php', post!, header, true, (result, error) {
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }
}
