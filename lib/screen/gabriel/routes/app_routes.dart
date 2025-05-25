import 'package:project_skripsi/screen/gabriel/checkouts/show_items_screen/show_items_screen.dart';
import 'package:project_skripsi/screen/gabriel/point_screen/point_cart_screen/point_cart_screen.dart';
import 'package:project_skripsi/screen/gabriel/request_item/request_item_screen/request_item_screen.dart';

import '../not_found_screen/not_found_screen.dart';
import '../core/app_export.dart';
import '../../auth/splash_screen.dart';

import '../checkouts/shopping_cart_screen/shopping_cart_screen.dart';
import '../point_screen/show_items_point_screen/show_items_point_screen.dart';

class AppRoutes {
  static const String notFoundScreen = '/not_found_screen';

  static const String initialRoute = '/initial_route';

  // Shopping Cart
  static const String shoppingCartScreen = '/shopping_cart_screen';
  static const String showItemsPointScreen = '/show_items_point_screen';
  static const String showItemsScreen = '/show_items_screen';
  static const String requestItemScreen = '/request_item_screen';
  static const String pointCartScreen = '/point_cart_screen';

  static Map<String, WidgetBuilder> allRoutes = {
    initialRoute: (context) => const SplashScreen(),
    notFoundScreen: (context) => const NotFoundScreen(),
    shoppingCartScreen: (context) {
      final items = ModalRoute.of(context)?.settings.arguments as List<dynamic>;
      return ShoppingCartScreen(items: items); // Pass items to CartPage
    },
    showItemsPointScreen: (context) => ShowItemsPointScreen(),
    showItemsScreen: (context) => ShowItemsScreen(),
    pointCartScreen: (context) {
      final items = ModalRoute.of(context)?.settings.arguments as List<dynamic>;
      return PointCartScreen(items: items); // Pass items to CartPage
    },
    requestItemScreen: (context) => RequestedItemScreen(),
  };
}
