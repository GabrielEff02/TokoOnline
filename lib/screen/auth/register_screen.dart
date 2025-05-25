import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constant/dialog_constant.dart';
import '../../constant/image_constant.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../constant/text_constant.dart';
import '../../controller/auth_controller.dart';
import '../../widget/material/button_green_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<RegisterScreen> {
  AuthController registercontroller = AuthController();
  String confirmPasswordCheck = '';
  String passwordCheck = '';
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.05),
              Center(
                  child: Image.asset(ImageConstant.cart_logo,
                      height: size.height * 0.15)),
              SizedBox(height: 45),
              Text(
                'Daftar',
                style: TextConstant.regular.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 20),

              // Email Field
              buildTextField('Email', registercontroller.edtEmail, 50,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icon(Icons.email, color: Colors.blue)),
              SizedBox(height: 20),
              // Phone Field
              buildTextField('Nomor Telepon', registercontroller.edtPhone, 13,
                  icon: Icon(Icons.phone, color: Colors.blueGrey),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(13),
                    FilteringTextInputFormatter.deny(
                        RegExp('[\\-|\\,|\\.|\\#|\\*]')),
                    FilteringTextInputFormatter.digitsOnly
                  ]),
              SizedBox(height: 20),

              // Password Field
              buildTextField('Kata Sandi', registercontroller.edtPass, 6,
                  obscureText: true,
                  icon: Icon(Icons.lock, color: Colors.orange), check: () {
                String password = registercontroller.edtPass.text;
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
                    passwordCheck = ''; // Tidak ada error
                  });
                }
              }),
              passwordCheck != ''
                  ? Text(passwordCheck, style: TextStyle(color: Colors.red))
                  : Container(),

              SizedBox(height: 20),
              // Confirm Password Field
              buildTextField(
                  'Konfirmasi Kata Sandi', registercontroller.edtConfirmPass, 6,
                  icon: Icon(Icons.lock_outline, color: Colors.green),
                  obscureText: true, check: () {
                String password = registercontroller.edtPass.text;
                String confirmPassword = registercontroller.edtConfirmPass.text;
                if (password.isEmpty) {
                  confirmPasswordCheck = 'Kata Sandi tidak boleh kosong!';
                } else if (confirmPassword.isNotEmpty &&
                    password != confirmPassword) {
                  setState(() {
                    confirmPasswordCheck =
                        'Kata Sandi dan Konfirmasi Kata Sandi tidak sama!';
                  });
                } else {
                  setState(() {
                    confirmPasswordCheck = '';
                  });
                }
              }),
              confirmPasswordCheck != ''
                  ? Text(confirmPasswordCheck,
                      style: TextStyle(color: Colors.red))
                  : Container(),
              SizedBox(height: 35),
              ButtonGreenWidget(
                text: 'Daftar',
                onClick: () {
                  // Validate fields
                  String email = registercontroller.edtEmail.text.trim();
                  if (email.isEmpty) {
                    DialogConstant.alert('Email tidak boleh kosong');
                    return;
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                    DialogConstant.alert('Masukkan email yang valid');
                    return;
                  }

                  String phoneNumber = registercontroller.edtPhone.text.trim();
                  if (phoneNumber.isEmpty) {
                    DialogConstant.alert('Nomor Telepon tidak boleh kosong');
                    return;
                  }
                  if (phoneNumber.length < 11 || phoneNumber.length > 13) {
                    DialogConstant.alert(
                        'Nomor Telepon harus antara 11 dan 13 digit');
                    return;
                  }

                  String password = registercontroller.edtPass.text.trim();
                  if (password.isEmpty) {
                    DialogConstant.alert('Kata Sandi tidak boleh kosong');
                    return;
                  }
                  if (password.length < 6) {
                    DialogConstant.alert('Kata Sandi harus minimal 6 karakter');
                    return;
                  }

                  String confirmPassword =
                      registercontroller.edtConfirmPass.text.trim();
                  if (confirmPassword.isEmpty) {
                    DialogConstant.alert(
                        'Konfirmasi Kata Sandi tidak boleh kosong');
                    return;
                  }
                  if (password != confirmPassword) {
                    DialogConstant.alert(
                        'Kata Sandi dan Konfirmasi tidak cocok');
                    return;
                  }

                  registercontroller.validationRegister(
                    context: context,
                    callback: (result, error) {
                      if (result != null && result['error'] != true) {
                        Get.back();
                        DialogConstant.alert('Pendaftaran Berhasil');
                      }
                      if (result['error'] == true) {
                        DialogConstant.alert(result['message']);
                      }
                      if (error != null) {
                        DialogConstant.alert('Pendaftaran Gagal');
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun ? ',
                      style: TextConstant.regular,
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Login',
                            style: TextConstant.regular
                                .copyWith(color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget buildTextField(
      String label, TextEditingController controller, int maxLength,
      {TextInputType keyboardType = TextInputType.text,
      required Icon icon,
      bool obscureText = false,
      Function? check,
      List<TextInputFormatter>? inputFormatters,
      bool password = false}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 8),
          password
              ? PinCodeTextField(
                  onChanged: (value) {
                    // controller.text = value.toUpperCase();
                    // controller.selection = TextSelection.fromPosition(
                    //   TextPosition(offset: controller.text.length),
                    // );
                    check!.call();
                  },
                  obscureText: true,
                  length: 6,
                  appContext: Get.context!,
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
                  controller: controller,
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    maxLength: maxLength,
                    controller: controller,
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    inputFormatters: inputFormatters,
                    decoration: InputDecoration(
                      counterText: "",
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.purple),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: "Masukkan $label",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: icon,
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    onChanged: (value) {
                      check?.call();
                    },
                  ),
                )
        ],
      ),
    );
  }
}
