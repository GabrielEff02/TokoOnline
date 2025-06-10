import 'package:project_skripsi/controller/auth_controller.dart';
import 'package:project_skripsi/screen/srg/verify_phone_screen.dart';

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
  Future<void> getSplashData() async {
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
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getSplashData();
      final authController = AuthController();
      if (await LocalData.getDataBool('isLoggedIn')) {
        String phone = await LocalData.getData('phone');
        String password = await LocalData.getData('password');

        authController.edtPhone.text = phone;
        authController.edtPass.text = password;

        authController.postLogin(
          context: context,
          callback: (result, exception) {
            print(result);
            if (result['data'][0]['register_confirmation'] != '1') {
              Get.back();

              Get.offAll(VerifyPhoneScreen());
            } else {
              Get.back();
            }
          },
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SecondSplash()),
      );
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
                "${API.BASE_URL}/img/splash/${SplashScreen.path1}",
              ),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
