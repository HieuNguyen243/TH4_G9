import 'product_model.dart';

// lib/models/cart_item_model.dart
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Tính tổng tiền cho một mặt hàng (Giá x Số lượng)
  double get totalPrice => product.price * quantity;
}
