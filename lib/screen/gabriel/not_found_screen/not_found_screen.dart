import 'package:get/get.dart';

import '../core/app_export.dart';

class NotFoundScreen extends StatefulWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  _NotFoundScreenState createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen> {
  late String route;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeArgument =
          ModalRoute.of(context)?.settings.arguments as String?;
      route = routeArgument ?? '';
      showAlertDialog(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Data Not Found")),
        body: InkWell(
            child: Center(
          child: Text(
            "Data Not Found.",
            style: TextStyle(
              fontSize: 18, // Gaya teks bisa disesuaikan sesuai kebutuhan
              fontWeight: FontWeight.bold,
            ),
          ),
        )));
  }
}

void showAlertDialog(BuildContext context, String route) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Data Not Found",
          style: TextStyle(
            fontSize: 20, // Gaya teks disesuaikan
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "There's No Data Found, Please Try Again!",
          style: TextStyle(
            fontSize: 16, // Gaya teks disesuaikan
            color: Colors.blueGrey[900], // Menggunakan warna yang sesuai
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Retry"),
            onPressed: () {
              route.isNotEmpty
                  ? Navigator.pushReplacementNamed(context, route)
                  : Get.back();
              Get.back();
            },
          ),
        ],
      );
    },
  );
}
