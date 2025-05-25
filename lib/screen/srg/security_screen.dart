import 'package:project_skripsi/constant/decoration_constant.dart';
import 'package:project_skripsi/screen/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:project_skripsi/utils/local_data.dart';

import '../../../constant/dialog_constant.dart';
import '../../../constant/image_constant.dart';
import '../../../constant/text_constant.dart';
import '../../../controller/auth_controller.dart';
import '../../../widget/material/button_green_widget.dart';

class SecurityScreen extends StatefulWidget {
  late bool forget;
  SecurityScreen({
    Key? key,
    bool? forget,
  }) : forget = false;

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  AuthController authController = Get.put(AuthController());
  String passwordCheck = '';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Keamanan Akun', style: TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  ImageConstant.ilus_forgot_pass,
                  height: size.height * 0.2,
                ),
              ),
              SizedBox(height: 25),
              Text(
                'Ubah Kata Sandi',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 10),
              Text(
                'Masukkan kata sandi baru dan kode verifikasi untuk mengamankan akun Anda.',
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
              SizedBox(height: 30),
              _buildPasswordInput(),
              if (passwordCheck.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    passwordCheck,
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              SizedBox(height: 25),
              _buildOTPInput(),
              SizedBox(height: 30),
              Center(
                child: ButtonGreenWidget(
                  text: 'Konfirmasi',
                  onClick: () => _submit(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Row(
      children: [
        Icon(Icons.lock, color: Colors.orange),
        SizedBox(width: 8),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 0),
            height: 45,
            child: TextField(
              maxLength: 25,
              controller: authController.changePass,
              obscureText: true,
              decoration: DecorationConstant.inputDecor().copyWith(
                hintText: "Masukkan Kata Sandi",
                counterText: '',
                contentPadding: EdgeInsets.only(top: 10, left: 10),
              ),
              onChanged: (value) {
                String password = value;

                if (password.isEmpty) {
                  setState(() {
                    passwordCheck = 'Password tidak boleh kosong!';
                  });
                } else if (password.length < 6) {
                  setState(() {
                    passwordCheck = 'Password harus minimal 6 karakter';
                    if (!RegExp(r'\d').hasMatch(password)) {
                      passwordCheck += ' & mengandung setidaknya 1 angka';
                    }
                    passwordCheck += '!!!';
                  });
                } else if (!RegExp(r'^(?=.*\d)[A-Za-z\d]{6,}$')
                    .hasMatch(password)) {
                  setState(() {
                    passwordCheck =
                        'Password harus mengandung setidaknya 1 angka!';
                  });
                } else {
                  setState(() {
                    passwordCheck = '';
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kode Verifikasi',
          style: TextConstant.regular.copyWith(
              fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 15),
        ),
        SizedBox(height: 5),
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
          controller: authController.otpCode,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () => authController.sendOtpSMS(
              context: Get.context!,
              callback: (result, error) {
                DialogConstant.alert(
                    'Kode verifikasi telah dikirim ke nomor Anda.');
              }),
          child: Text(
            'Kirim ulang kode verifikasi',
            style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    authController.changePass.text = "";
    authController.otpCode.text = "";
  }

  void _submit() {
    if (passwordCheck == '') {
      authController.validationOtp(
        context: Get.context!,
        callback: (result, error) async {
          if (result != null && result['error'] != true) {
            LocalData.saveData('password', authController.changePass.text);
            authController.changePass.text = "";
            authController.otpCode.text = "";
            DialogConstant.showSnackBar("Kata sandi berhasil diubah!");
            Get.offAll(LoginScreen());
          } else {
            DialogConstant.alert('Kode verifikasi salah!');
          }
        },
      );
    } else {
      DialogConstant.alert(passwordCheck);
    }
  }
}
