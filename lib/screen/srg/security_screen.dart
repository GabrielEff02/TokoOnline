import 'package:project_skripsi/constant/decoration_constant.dart';
import 'package:project_skripsi/screen/auth/login_screen.dart';
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

class _SecurityScreenState extends State<SecurityScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();

    authController.sendOtpSMS(
        context: Get.context!,
        callback: (result, error) {
          DialogConstant.alert('Kode verifikasi telah dikirim ke nomor Anda.');
        });
  }

  AuthController authController = Get.put(AuthController());
  String passwordCheck = '';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Keamanan Akun',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            )),
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: Colors.black87, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section with Image
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade50,
                          Colors.indigo.shade50,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            ImageConstant.ilus_forgot_pass,
                            height: size.height * 0.12,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Ubah Kata Sandi',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Masukkan kata sandi baru dan kode verifikasi untuk mengamankan akun Anda.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Password Input Section
                  _buildPasswordSection(),

                  SizedBox(height: 30),

                  // OTP Input Section
                  _buildOTPSection(),

                  SizedBox(height: 40),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ButtonGreenWidget(
                      text: 'Konfirmasi',
                      onClick: () => _submit(),
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Kata Sandi Baru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: passwordCheck.isNotEmpty
                    ? Colors.red.shade300
                    : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: TextField(
              maxLength: 25,
              controller: authController.changePass,
              obscureText: true,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: "Masukkan kata sandi baru",
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
                counterText: '',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                border: InputBorder.none,
                suffixIcon: passwordCheck.isEmpty &&
                        authController.changePass.text.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.all(12),
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.green.shade600,
                          size: 16,
                        ),
                      )
                    : null,
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
          if (passwordCheck.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red.shade600,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        passwordCheck,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOTPSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Kode Verifikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Masukkan 4 digit kode yang telah dikirim',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 20),
          PinCodeTextField(
            length: 4,
            appContext: Get.context!,
            keyboardType: TextInputType.number,
            animationType: AnimationType.fade,
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(16),
              fieldHeight: 58,
              fieldWidth: 58,
              activeFillColor: Colors.blue.shade50,
              inactiveFillColor: Colors.grey.shade50,
              selectedFillColor: Colors.blue.shade50,
              inactiveColor: Colors.grey.shade300,
              selectedColor: Colors.blue.shade400,
              activeColor: Colors.blue.shade500,
              borderWidth: 2,
            ),
            enableActiveFill: true,
            controller: authController.otpCode,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => authController.sendOtpSMS(
                  context: Get.context!,
                  callback: (result, error) {
                    DialogConstant.alert(
                        'Kode verifikasi telah dikirim ke nomor Anda.');
                  }),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: Colors.blue.shade600,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Kirim ulang kode verifikasi',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
