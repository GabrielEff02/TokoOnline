import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constant/decoration_constant.dart';
import '../../constant/dialog_constant.dart';
import '../../constant/image_constant.dart';
import '../../constant/text_constant.dart';
import '../../controller/auth_controller.dart';
import '../../screen/auth/forgot_password_screen.dart';
import '../../screen/auth/splash_screen.dart';
import '../srg/verify_phone_screen.dart';
import '../../screen/auth/register_screen.dart';
import '../../utils/local_data.dart';
import '../../widget/material/button_green_widget.dart';

class LoginScreen extends StatefulWidget {
  static int? notification; // Static member

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthController logincontroller = AuthController();
  @override
  void initState() {
    alreadyLogIn();
    super.initState();
  }

  Future<void> alreadyLogIn() async {
    if (await LocalData.containsKey('phone') &&
        await LocalData.containsKey('password')) {
      logincontroller.edtPhone.text = await LocalData.getData('phone');
      logincontroller.edtPass.text = await LocalData.getData('password');
      // clearCart();
      logincontroller.validation(
        context: context,
        callback: (result, error) async {
          if (result != null && result['error'] != true) {
            if (result['data'][0]['register_confirmation'] == '0') {
              Get.to(() => VerifyPhoneScreen());
            } else {
              // Get.offAll(KtpOCR());
              Get.offAll(SplashScreen());
            }
          } else {
            DialogConstant.alert(error.toString());
          }
        },
      );
    } else {
      clearCart();
    }
  }

  clearCart() {
    LocalData.removeAllPreference();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Obx(() => Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.10),
                  Center(
                      child: Image.asset(ImageConstant.cart_logo,
                          height: size.height * 0.20)),
                  SizedBox(height: 35),
                  Text(
                    'Login',
                    style: TextConstant.regular.copyWith(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 45),
                  Container(
                    child: Row(
                      children: [
                        Icon(Icons.phone_android_rounded,
                            size: 24, color: Colors.grey.shade400),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            height: 40,
                            child: TextField(
                              maxLength: 25,
                              controller: logincontroller.edtPhone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(13),
                                FilteringTextInputFormatter.deny(
                                    RegExp('[\\-|\\,|\\.|\\#|\\*]')),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: DecorationConstant.inputDecor()
                                  .copyWith(
                                      hintText: "Masukkan Nomor Telephone",
                                      counterText: '',
                                      contentPadding: EdgeInsets.only(top: 0)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    child: Row(
                      children: [
                        Icon(
                          Icons.https,
                          size: 24,
                          color: Colors.grey.shade400,
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            height: 40,
                            child: TextField(
                              maxLength: 25,
                              controller: logincontroller.edtPass,
                              obscureText: logincontroller.openPassLogin.value,
                              decoration:
                                  DecorationConstant.inputDecor().copyWith(
                                hintText: "Masukkan Kata Sandi",
                                counterText: '',
                                contentPadding: EdgeInsets.only(top: 10),
                                suffixIcon: GestureDetector(
                                    onTap: () => logincontroller
                                        .changeOpenPassLogin(!logincontroller
                                            .openPassLogin.value),
                                    child: Icon(
                                      logincontroller.openPassLogin.value
                                          ? CupertinoIcons.eye_slash
                                          : CupertinoIcons.eye,
                                      size: 20,
                                      color: Colors.grey.shade400,
                                    )),
                                suffixIconColor: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () => Get.to(() => ForgotPasswordScreen()),
                            child: Text(
                              'Lupa Kata Sandi?',
                              style: TextConstant.regular.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: ButtonGreenWidget(
                        text: 'Submit',
                        onClick: () {
                          logincontroller.validation(
                              context: context,
                              callback: (result, error) async {
                                if (result != null && result['error'] != true) {
                                  if (result['data'][0]
                                          ['register_confirmation'] ==
                                      '0') {
                                    Get.to(() => VerifyPhoneScreen());
                                  } else {
                                    Get.offAll(SplashScreen());
                                  }
                                } else {
                                  DialogConstant.alert(error);
                                }
                              });
                        },
                      )),
                  SizedBox(height: 15),
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.to(() => RegisterScreen()),
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum punya akun ? Daftar',
                          style: TextConstant.regular,
                          children: <TextSpan>[
                            TextSpan(
                                text: ' Disini',
                                style: TextConstant.regular
                                    .copyWith(color: Colors.green)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.to(() => SplashScreen()),
                      child: Text(
                        'Jangan Sekarang',
                        style: TextConstant.regular.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
