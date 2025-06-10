import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import '../../../constant/decoration_constant.dart';
import '../../../constant/dialog_constant.dart';
import '../../../constant/image_constant.dart';
import '../../../constant/text_constant.dart';
import '../../../controller/auth_controller.dart';
import '../../../screen/home/landing_home.dart';
import '../../../screen/ocr_ktp/view/home.dart';
import '../../../utils/local_data.dart';
import '../../../widget/material/button_green_widget.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({Key? key}) : super(key: key);

  @override
  _VerifyPhoneScreenState createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen>
    with TickerProviderStateMixin {
  final AuthController authController = AuthController();
  String phoneNumber = '';
  bool isLoading = false;
  bool isResendLoading = false;
  Timer? _timer;
  int _resendCountdown = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
    _initializeAnimations();
    _startInitialCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  void _loadPhoneNumber() async {
    String? phone = await LocalData.getData('phone');
    setState(() {
      phoneNumber = phone ?? '';
    });
  }

  void _startInitialCountdown() {
    setState(() {
      authController.sendVerifyCode(
        context: context,
        callback: (result, error) {
          setState(() {
            isResendLoading = false;
            if (result != null && result['error'] != true) {
              _resendCountdown = 30;

              _startCountdown();
            }
          });

          if (result != null && result['error'] != true) {
            _showSuccessMessage('Kode verifikasi telah dikirimkan');
          } else {
            DialogConstant.alert(error ?? 'Gagal mengirim kode verifikasi');
          }
        },
      );
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length >= 4) {
      return phone.replaceAll(RegExp(r'\d(?=\d{4})'), '*');
    }
    return phone;
  }

  void _resendCode() async {
    if (_resendCountdown > 0 || isResendLoading) return;

    setState(() {
      isResendLoading = true;
    });

    authController.sendVerifyCode(
      context: context,
      callback: (result, error) {
        setState(() {
          isResendLoading = false;
          if (result != null && result['error'] != true) {
            _resendCountdown = 30;
            _startCountdown();
          }
        });

        if (result != null && result['error'] != true) {
          _showSuccessMessage('Kode verifikasi telah dikirim ulang!');
        } else {
          DialogConstant.alert(error ?? 'Gagal mengirim kode verifikasi');
        }
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _submitVerification() async {
    if (authController.verifyCode.text.length != 4) {
      DialogConstant.alert('Mohon masukkan kode verifikasi 4 digit');
      return;
    }

    setState(() {
      isLoading = true;
    });

    authController.validationVerify(
      context: context,
      callback: (result, error) async {
        setState(() {
          isLoading = false;
        });

        if (result != null && result['error'] != true) {
          // Show success animation
          _showSuccessDialog();
        } else {
          DialogConstant.alert(
              result?['message'] ?? 'Kode verifikasi tidak valid');
        }
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verifikasi Berhasil!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Nomor telepon Anda telah berhasil diverifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );

    // Navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(() => LandingHome());
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Header Section
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.phone_android_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Verifikasi Nomor Telepon',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Masukkan kode verifikasi 4 digit yang telah dikirim ke WhatsApp Anda',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Phone Number Display
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nomor WhatsApp',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _maskPhoneNumber(phoneNumber),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // PIN Input Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Masukkan Kode Verifikasi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          PinCodeTextField(
                            length: 4,
                            appContext: context,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.scale,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(12),
                              fieldHeight: 60,
                              fieldWidth: 60,
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white.withOpacity(0.1),
                              selectedFillColor: Colors.white.withOpacity(0.2),
                              inactiveColor: Colors.white.withOpacity(0.3),
                              selectedColor: Colors.white,
                              activeColor: Colors.white,
                              borderWidth: 2,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF667eea),
                            ),
                            controller: authController.verifyCode,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onCompleted: (code) {
                              // Auto submit when 4 digits are entered
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                _submitVerification();
                              });
                            },
                            enableActiveFill: true,
                            cursorColor: Colors.white,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Resend Code Section
                    Center(
                      child: _resendCountdown > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Kirim ulang dalam ${_resendCountdown}s',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: _resendCode,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isResendLoading)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isResendLoading
                                          ? 'Mengirim...'
                                          : 'Kirim Ulang Kode',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4facfe),
                            Color(0xFF00f2fe),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4facfe).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Memverifikasi...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Verifikasi Sekarang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
