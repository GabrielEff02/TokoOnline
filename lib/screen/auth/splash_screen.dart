import 'package:project_skripsi/controller/auth_controller.dart';
import 'package:project_skripsi/screen/srg/verify_phone_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../../screen/gabriel/core/app_export.dart';
import '../../screen/auth/second_splash.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  final int? notification;

  const SplashScreen({super.key, this.notification});

  static String path1 = "";
  static String path2 = "";
  static Map<String, dynamic> notificationData = {};

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  Future<void> getSplashData() async {
    try {
      final fetchData = await Splash.getSplashData();
      final random = Random();
      setState(() {
        if (random.nextBool()) {
          SplashScreen.path1 = fetchData[0];
          SplashScreen.path2 = fetchData[1];
        } else {
          SplashScreen.path1 = fetchData[1];
          SplashScreen.path2 = fetchData[0];
        }
      });

      SplashScreen.notificationData = await Splash.getNotification();
    } catch (e) {
      // If getSplashData fails, it might be due to network issues
      // Set default values or rethrow the error
      throw e;
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Additional check: try to make a simple network request
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red),
              SizedBox(width: 10),
              Text(
                'Tidak Ada Koneksi Internet',
                maxLines: 2,
              ),
            ],
          ),
          content: const Text(
            'Pastikan perangkat Anda terhubung ke internet untuk melanjutkan.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeApp();
              },
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // Close the app
              },
              child: const Text(
                'Keluar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
    });

    // Check internet connection first
    final hasInternet = await _checkInternetConnection();

    if (!hasInternet) {
      setState(() {
        _isLoading = false;
      });
      _showNoInternetDialog();
      return;
    }

    try {
      await getSplashData();
      final authController = AuthController();
      if (await LocalData.getDataBool('isLoggedIn')) {
        String phone = await LocalData.getData('phone');
        String password = await LocalData.getData('password');

        authController.edtPhone.text = phone;
        authController.edtPass.text = password;

        await authController.postLogin(
          context: context,
          callback: (result, exception) {
            if (result['data'][0]['register_confirmation'] != '1') {
              Get.offAll(VerifyPhoneScreen());
            } else {
              Get.to(SecondSplash());
            }
          },
        );
      } else {
        Get.to(SecondSplash());
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = true;
      });

      // Show error dialog for other errors (like server issues)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 10),
                Text('Terjadi Kesalahan'),
              ],
            ),
            content: Text(
              'Gagal memuat data aplikasi. ${e.toString()}',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _initializeApp();
                },
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "${API.BASE_URL}/img/splash/${SplashScreen.path1}"),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
