import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  // Map lưu trữ giỏ hàng: Key là ID sản phẩm, Value là CartItem
  final Map<int, CartItem> _items = {};

  // Lấy danh sách sản phẩm trong giỏ hàng
  Map<int, CartItem> get items => {..._items};

  // Tính tổng số lượng mặt hàng trong giỏ
  int get itemCount => _items.length;

  // Tính tổng số tiền trong giỏ hàng
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  // 1. Hàm thêm sản phẩm vào giỏ hàng
  void addToCart(ProductModel product) {
    if (_items.containsKey(product.id)) {
      // Nếu đã có trong giỏ, tăng số lượng
      _items.update(
        product.id,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      // Nếu chưa có, thêm mới
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    notifyListeners(); // Thông báo cho UI cập nhật
  }

  // 2. Hàm xóa sản phẩm khỏi giỏ hàng
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // 3. Hàm giảm số lượng hoặc xóa nếu số lượng = 1
  void removeSingleItem(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // 4. Hàm làm trống giỏ hàng (khi đặt hàng thành công)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
