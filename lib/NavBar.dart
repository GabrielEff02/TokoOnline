import 'package:project_skripsi/screen/auth/login_screen.dart';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';
import 'package:project_skripsi/screen/gabriel/request_item/request_history_screen/request_history_screen.dart';
import 'package:project_skripsi/screen/home/view/edit_profile_screen.dart';
import 'package:project_skripsi/screen/navbar_menu/about_us_screen.dart';
import 'package:project_skripsi/screen/navbar_menu/alamat_screen.dart';
import 'package:project_skripsi/screen/navbar_menu/history_screen.dart';
import 'package:project_skripsi/screen/navbar_menu/others_screen.dart';
import 'package:project_skripsi/screen/navbar_menu/contact_screen.dart';
import 'package:project_skripsi/screen/navbar_menu/outlet_screen.dart';
import 'package:project_skripsi/screen/ocr_ktp/view/home.dart';
import 'package:project_skripsi/screen/srg/security_screen.dart';
import 'package:get/get.dart';

import 'screen/navbar_menu/checkout_main_screen.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
              margin: EdgeInsets.fromLTRB(10.h, 30.v, 10.h, 10.v),
              child: Image.asset(
                'assets/images/logo.png',
                width: 150.adaptSize,
                height: 150.adaptSize,
              )),

          // ListTile(
          //   leading: Icon(Icons.person),
          //   title: Text('Friends'),
          //   onTap: () => null,
          // ),

          // ListTile(
          //   leading: Icon(Icons.notifications),
          //   title: Text('Request'),
          //   onTap: () => null,
          //   trailing: ClipOval(
          //     child: Container(
          //       color: Colors.red,
          //       width: 20,
          //       height: 20,
          //       child: Center(
          //         child: Text(
          //           '8',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 12,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // ListTile(
          //   leading: Icon(Icons.shop),
          //   title: Text('Checkouts Cart'),
          //   // onTap: () => Get.to(() => CheckoutsSplashScreen()),
          //   onTap: () => mainCheckouts(),
          // ),

          FutureBuilder<bool>(
            future: LocalData.getDataBool('isLoggedIn'),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!) {
                return Column(
                  children: [
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline,
                                size: 48, color: Colors.indigo),
                            const SizedBox(height: 12),
                            Text(
                              'Harap login terlebih dahulu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade900,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => Get.to(() => LoginScreen()),
                              label: Text('Login Sekarang'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text('Redeem your points'),
                    onTap: () => Get.to(() => CheckoutMainScreen()),
                  ),
                  ListTile(
                    leading: Icon(Icons.request_page),
                    title: Text('Request Item'),
                    onTap: () => Get.to(() => RequestHistoryScreen()),
                  ),
                  ListTile(
                    leading: Icon(Icons.history_edu),
                    title: Text('Riwayat Transaksi'),
                    onTap: () => Get.to(() => HistoryScreen()),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Change Password'),
                    onTap: () => Get.to(() => SecurityScreen()),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Edit Profile'),
                    onTap: () => Get.to(() => EditProfileScreen()),
                  ),
                  ListTile(
                    leading: Icon(Icons.person_add),
                    title: Text('Complete your details'),
                    onTap: () => Get.to(() => KtpOCR()),
                  ),
                  ListTile(
                    leading: Icon(Icons.house),
                    title: Text('Alamat Pengiriman'),
                    onTap: () => Get.to(() => AlamatScreen()),
                  ),
                ],
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.house),
            title: Text('Tiara Outlet Store'),
            onTap: () => Get.to(() => OutletScreen()),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Contact US'),
            onTap: () => Get.to(() => ContactScreen()),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.more_horiz),
            title: Text('Others'),
            onTap: () => Get.to(() => OthersScreen()),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About US'),
            onTap: () => Get.to(() => AboutUsScreen()),
          ),
          FutureBuilder<bool>(
              future: LocalData.getDataBool('isLoggedIn'),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!) {
                  return Container();
                }
                return Column(
                  children: [
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.exit_to_app_rounded),
                      title: Text('Log Out'),
                      onTap: () {
                        LocalData.removeAllPreference();
                        Get.offAll(const LoginScreen());
                      },
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
