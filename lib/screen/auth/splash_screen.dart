import '../../screen/gabriel/core/app_export.dart';
import '../../screen/auth/second_splash.dart';
import 'dart:math';

class SplashScreen extends StatelessWidget {
  final int? notification;

  const SplashScreen({super.key, this.notification});

  static String path1 = "";
  static String path2 = "";
  static Map<String, dynamic> notificationData = {};
  static Future<void> getSplashData() async {
    final fetchData = await Splash.getSplashData();
    final random = Random();
    if (random.nextBool()) {
      SplashScreen.path1 = fetchData[0];
      SplashScreen.path2 = fetchData[1];
    } else {
      SplashScreen.path1 = fetchData[1];
      SplashScreen.path2 = fetchData[0];
    }

    SplashScreen.notificationData = await Splash.getNotification();
  }

  @override
  Widget build(BuildContext context) {
    // Navigate to the SecondSplash screen after a delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SecondSplash()),
        );
      });
    });

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  NetworkImage("${API.BASE_URL}/images/${SplashScreen.path1}"),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
