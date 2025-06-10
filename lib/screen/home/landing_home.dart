import 'package:http/http.dart';
import 'package:project_skripsi/NavBar.dart';
import 'package:project_skripsi/api/notification_api.dart';
import 'package:project_skripsi/controller/auth_controller.dart';
import 'package:project_skripsi/screen/auth/login_screen.dart';
import 'package:project_skripsi/screen/auth/splash_screen.dart';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';
import 'package:project_skripsi/screen/gabriel/notifications/notification_screen.dart';
import 'package:project_skripsi/screen/home/view/landing_screen.dart';
import 'package:project_skripsi/screen/home/view/search_product_screen.dart';
import 'package:project_skripsi/screen/home/view/wheel_fortune.dart';
import 'package:project_skripsi/screen/srg/verify_phone_screen.dart';
import 'package:project_skripsi/widget/material/button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LandingHome extends StatefulWidget {
  const LandingHome({Key? key}) : super(key: key);
  static bool wait = false;
  @override
  State<LandingHome> createState() => _LandingHomeState();
}

class _LandingHomeState extends State<LandingHome>
    with TickerProviderStateMixin {
  PageController controllers = PageController();
  late AnimationController _controller;
  late Animation<double> _swingAnimation;
  bool isLoggedIn = false;
  // Button state
  bool buttonPressed1 = true;
  bool buttonPressed2 = false;
  bool buttonPressed3 = false;
  List<Widget> actions = [];
  @override
  void dispose() {
    controllers.dispose();
    super.dispose();
  }

  void getLoggedIn() async {
    final data = await LocalData.getDataBool('isLoggedIn');

    setState(() {
      isLoggedIn = data;
      if (isLoggedIn) {
        actions = [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, AppRoutes.showItemsScreen);
            },
            icon: Icon(
              Icons.shopping_cart,
              color: const Color.fromARGB(255, 245, 198, 78),
              size: 35.0,
            ), // Jika tidak ada notifikasi, ikon biasa
          ),
          IconButton(
            onPressed: () {
              Get.to(NotificationScreen());
            },
            icon: SplashScreen.notificationData['count'] != null &&
                    SplashScreen.notificationData['count'] > 0
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _swingAnimation.value, // Swing effect
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.notifications,
                          color: const Color(0xFF0095FF),
                          size: 35.0,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20.0,
                            minHeight: 20.0,
                          ),
                          child: Center(
                            child: Text(
                              SplashScreen.notificationData['count'].toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    Icons.notifications,
                    color: const Color.fromARGB(255, 78, 175, 245),
                    size: 35.0,
                  ), // Jika tidak ada notifikasi, ikon biasa
          ),
        ];
      } else {
        actions = [
          Container(
            margin: EdgeInsets.all(8.adaptSize),
            child: TextButton.icon(
              onPressed: () => Get.to(LoginScreen()),
              icon: Icon(Icons.login, color: Colors.white),
              label: Text('Login', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 68, 189, 249),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          )
        ];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  Future<void> loadInitialData() async {
    setState(() {
      LandingHome.wait = true;
    });
    DialogConstant.loading(context, 'Loading...');
    getLoggedIn();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _swingAnimation = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );

    if (SplashScreen.notificationData['count'] != null &&
        SplashScreen.notificationData['count'] > 0) {
      _controller.repeat(reverse: true);
    }
    if (NotificationApi.notificationId != 0) {
      Get.to(NotificationScreen());
    }
    Get.back();
    setState(() {
      LandingHome.wait = false;
    });
  }

  void _navigateToPage(int pageIndex) {
    setState(() {
      buttonPressed1 = pageIndex == 0;
      buttonPressed2 = pageIndex == 1;
      buttonPressed3 = pageIndex == 2;
    });
    // Menggunakan animateToPage dengan durasi dan curve untuk transisi yang lebih smooth
    controllers.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500), // Durasi transisi
      curve: Curves.easeInOut, // Efek curve untuk transisi halus
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buttonPressed1
          ? AppBar(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text(
                    "Tiara Dewata",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                ),
              ),
              actions: actions,
            )
          : null,
      drawer: buttonPressed1 ? NavBar() : null,
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: controllers,
            children: const <Widget>[
              LandingScreen(),
              SearchProductScreen(),
              SpiningWheel(),
            ],
            onPageChanged: (val) {
              setState(() {
                buttonPressed1 = val == 0;
                buttonPressed2 = val == 1;
                buttonPressed3 = val == 2;
              });
            },
          ),
          // Neumorphic buttons for navigation
          Positioned(
            bottom: 20,
            left: 50,
            right: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _navigateToPage(0), // Navigate to LandingScreen
                    child: buttonPressed1
                        ? ButtonTapped(
                            icon: Icons.home,
                            color: Colors.amber,
                          )
                        : MyButton(
                            icon: Icons.home,
                            color: Colors.amber,
                          ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _navigateToPage(1), // Navigate to SpinningWheel
                    child: buttonPressed2
                        ? ButtonTapped(icon: Icons.search, color: Colors.red)
                        : MyButton(icon: Icons.search, color: Colors.red),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _navigateToPage(2), // Navigate to ProfileScreen
                    child: buttonPressed3
                        ? ButtonTapped(
                            icon: FontAwesomeIcons.bullseye, color: Colors.blue)
                        : MyButton(
                            icon: FontAwesomeIcons.bullseye,
                            color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
