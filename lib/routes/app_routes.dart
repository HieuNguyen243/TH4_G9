import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../views/home/home_screen.dart';
import '../views/detail/product_detail_screen.dart';
import '../views/cart/cart_screen.dart';
import '../views/checkout/checkout_screen.dart';

class AppRoutes {
  // Định nghĩa tên các route (Màn hình) của ứng dụng
  static const String home = '/';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';

  // Quản lý tất cả các Route của dự án một cách tập trung
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );

      case productDetail:
        // Lấy đối số (arguments) truyền vào Route (là một ProductModel)
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        );

      case cart:
        return MaterialPageRoute(
          builder: (context) => const CartScreen(),
        );

      case checkout:
        return MaterialPageRoute(
          builder: (context) => const CheckoutScreen(),
        );

      case orders:
        // TODO: Màn hình đơn hàng thành công (Bạn C làm)
        return MaterialPageRoute(
          builder: (context) => const Scaffold(body: Center(child: Text('Orders Screen'))),
        );

      default:
        // Màn hình lỗi (trường hợp gọi route không tồn tại)
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Lỗi: Route không tồn tại!')),
          ),
        );
    }
  }
}
