import 'package:project_skripsi/api/api.dart';
import 'package:project_skripsi/screen/auth/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screen/home/landing_home.dart';

class SecondSplash extends StatefulWidget {
  const SecondSplash({super.key});

  @override
  State<SecondSplash> createState() => _SecondSplashState();
}

class _SecondSplashState extends State<SecondSplash>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LandingHome()),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                "${API.BASE_URL}/img/splash/${SplashScreen.path2}"),
            fit: BoxFit.fill,
          ),
        ),
      ),
    ));
  }
}
