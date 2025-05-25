import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../constant/decoration_constant.dart';
import '../../../constant/dialog_constant.dart';
import '../../../constant/image_constant.dart';
import '../../../constant/text_constant.dart';
import '../../../controller/auth_controller.dart';
import '../../../screen/home/landing_home.dart';
import '../../../screen/ocr_ktp/view/home.dart';
import '../../../utils/local_data.dart';
import '../../../widget/material/button_green_widget.dart';

class VerifyPhoneScreen extends StatelessWidget {
  VerifyPhoneScreen({Key? key}) : super(key: key);

  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  ImageConstant.ilus_forgot_pass,
                  height: size.height * 0.20,
                ),
              ),
              SizedBox(height: 45),
              Text(
                'Belum\nVerifikasi?',
                style: TextConstant.regular.copyWith(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 30),
              FutureBuilder(
                future: LocalData.getData('phone'),
                builder: (context, snapshot) {
                  return Text(
                    'Silahkan masukkan kode verifikasi yang telah dikirim ke Whatsapp Anda (${snapshot.data!.replaceAll(RegExp(r'\d(?=\d{4})'), '*')})',
                    style: TextConstant.regular.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  );
                },
              ),
              SizedBox(height: 45),
              PinCodeTextField(
                length: 4,
                appContext: Get.context!,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.grey.shade200,
                  selectedFillColor: Colors.white,
                  inactiveColor: Colors.grey.shade400,
                  selectedColor: Colors.blueAccent,
                  activeColor: Colors.blueAccent,
                ),
                controller: authController.verifyCode,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 15),
              Center(
                child: GestureDetector(
                  onTap: () => authController.sendVerifyCode(
                    context: context,
                    callback: (result, error) {
                      DialogConstant.alert('Kode Verifikasi telah dikirimkan!');
                    },
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Kirim',
                      style: TextConstant.regular.copyWith(color: Colors.green),
                      children: [
                        TextSpan(
                          text: ' Ulang kode?',
                          style: TextConstant.regular,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ButtonGreenWidget(
                text: 'Submit',
                onClick: () => authController.validationVerify(
                  context: context,
                  callback: (result, error) async {
                    if (result != null && result['error'] != true) {
                      Get.offAll(LandingHome());
                    } else {
                      DialogConstant.alert(result['message']);
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
