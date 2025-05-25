import 'package:project_skripsi/constant/dialog_constant.dart';
import 'package:project_skripsi/controller/auth_controller.dart';
import 'package:project_skripsi/screen/srg/security_screen.dart';
import 'package:project_skripsi/utils/local_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constant/decoration_constant.dart';
import '../../constant/image_constant.dart';
import '../../constant/text_constant.dart';
import '../../widget/material/button_green_widget.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);
  AuthController logincontroller = new AuthController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () => Get.back(),
            child: Icon(CupertinoIcons.back, color: Colors.black87)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Image.asset(ImageConstant.ilus_forgot_pass,
                      height: size.height * 0.20)),
              SizedBox(height: 45),
              Text(
                'Lupa\nKata Sandi?',
                style: TextConstant.regular.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 30),
              Text(
                'Jangan khawatir, Silahkan masukkan Nomor Telephone yang terhubung dengan akun anda',
                style: TextConstant.regular
                    .copyWith(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 45),
              Container(
                child: Row(
                  children: [
                    Icon(Icons.person, size: 24, color: Colors.grey.shade400),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        height: 40,
                        child: TextField(
                          controller: logincontroller.edtPhone,
                          maxLength: 25,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(13),
                            FilteringTextInputFormatter.deny(
                                RegExp('[\\-|\\,|\\.|\\#|\\*]')),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: DecorationConstant.inputDecor().copyWith(
                              hintText: "Masukkan Nomor Telephone anda",
                              counterText: '',
                              contentPadding: EdgeInsets.only(top: 0)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30),
              ButtonGreenWidget(
                text: 'Submit',
                onClick: () {
                  LocalData.saveData('phone', logincontroller.edtPhone.text);
                  logincontroller.sendOtpSMS(
                    context: context,
                    callback: (result, error) {
                      if (result != null && result['error'] != true) {
                        Get.to(SecurityScreen(
                          forget: true,
                        ));
                      } else {
                        LocalData.removeAllPreference();
                        DialogConstant.alert(result['message']);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
