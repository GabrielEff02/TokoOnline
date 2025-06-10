import 'package:project_skripsi/api/notification_api.dart';
import 'package:project_skripsi/screen/auth/splash_screen.dart';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';
import 'package:project_skripsi/screen/gabriel/not_found_screen/not_found_screen.dart';
import 'package:project_skripsi/screen/gabriel/notifications/inbox_screen.dart';
import 'package:project_skripsi/screen/gabriel/notifications/item_screen.dart';
import 'package:project_skripsi/screen/gabriel/notifications/promotion_screen.dart';
import 'package:get/get.dart';

void main() {
  Get.testMode = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NotificationScreen(),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notifications = SplashScreen.notificationData['data'] ?? [];
  dynamic productDatas;

  Future<void> getProductData() async {
    final fetchData = await CheckoutsData.getInitData("all");

    setState(() {
      productDatas = fetchData['productData'];
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (NotificationApi.notificationId != 0) {
          movePage(false, NotificationApi.notificationId);
        }
      });
    });

    getProductData();
    super.initState();
  }

  void _markAsRead(int index) {
    setState(() {
      notifications.forEach((item) {
        if (item['id'] == index) {
          item['isRead'] = 1;
        }
      });
      SplashScreen.notificationData['count'] -= 1;
    });
    API.basePost(
        '/api/toko/update_notif',
        <String, dynamic>{'id': index},
        <String, String>{'Content-Type': 'application/json'},
        true, (result, error) {
      print(result);
    });
  }

  void movePage(bool isRead, int id) {
    final notifications = SplashScreen.notificationData['data'];
    late final notification;

    notifications.forEach((item) {
      if (id == item['id']) {
        notification = item;
        return;
      }
    });

    !isRead ? _markAsRead(notification['id']) : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notification['type'] == 'inbox') {
        Get.to(() => InboxScreen(message: notification));
      } else if (notification['type'] == 'newItem') {
        dynamic productData;
        productDatas.forEach((item) {
          if (item['product_id'] == notification['product_id']) {
            productData = item;
            return;
          }
        });
        Get.to(() => productData != null
            ? ItemScreen(
                data: productData,
                isPoint: false,
              )
            : NotFoundScreen());
      } else if (notification['type'] == 'promotion') {
        Get.to(PromotionScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Daftar Notifikasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: notifications.isEmpty
            ? Center(
                child: Text(
                  "No notifications available",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView(
                children: notifications.map((notification) {
                  bool isRead = notification['isRead'] == 1 ? true : false;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: isRead ? Colors.white : Colors.yellow[50],
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      title: Text(
                        notification['title'],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        notification['message'],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      trailing: isRead
                          ? null
                          : Icon(
                              Icons.mark_as_unread,
                              color: Colors.blueAccent,
                            ),
                      onTap: () {
                        movePage(isRead, notification['id']);
                      },
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
