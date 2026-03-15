import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  // ─── Dữ liệu giỏ hàng ────────────────────────────────────────────────────
  // Map lưu trữ giỏ hàng: Key là ID sản phẩm, Value là CartItem
  final Map<int, CartItem> _items = {};

  // ─── Checkbox: Set chứa ID các sản phẩm đang được chọn ──────────────────
  final Set<int> _selectedIds = {};

  // ─── Getters: Giỏ hàng ───────────────────────────────────────────────────

  /// Toàn bộ sản phẩm trong giỏ (bản sao)
  Map<int, CartItem> get items => {..._items};

  /// Tổng số dòng (mặt hàng khác nhau) trong giỏ
  int get itemCount => _items.length;

  /// Tổng số lượng của tất cả sản phẩm (kể cả quantity)
  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  // ─── Getters: Checkbox ────────────────────────────────────────────────────

  /// Set ID các sản phẩm đang được tích checkbox
  Set<int> get selectedIds => {..._selectedIds};

  /// Kiểm tra một sản phẩm có đang được chọn không
  bool isSelected(int productId) => _selectedIds.contains(productId);

  /// Tất cả các item đều đang được chọn không?
  bool get isAllSelected =>
      _items.isNotEmpty && _selectedIds.length == _items.length;

  /// Có ít nhất 1 item được chọn và không phải tất cả (trạng thái trung gian)
  bool get isIndeterminate =>
      _selectedIds.isNotEmpty && _selectedIds.length < _items.length;

  /// Tổng tiền CHỈ TÍNH những item đang được tích checkbox
  double get selectedTotalAmount {
    double total = 0.0;
    _items.forEach((id, cartItem) {
      if (_selectedIds.contains(id)) {
        total += cartItem.totalPrice;
      }
    });
    return total;
  }

  /// Số lượng item đang được chọn
  int get selectedItemCount => _selectedIds.length;

  // ─── Logic: Giỏ hàng ─────────────────────────────────────────────────────

  /// 1. Thêm sản phẩm vào giỏ hàng
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
      // Nếu chưa có, thêm mới và TỰ ĐỘNG tích checkbox
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
      _selectedIds.add(product.id); // Auto-select sản phẩm mới thêm
    }
    notifyListeners();
  }

  /// 2. Xóa hoàn toàn một sản phẩm khỏi giỏ hàng
  void removeItem(int productId) {
    _items.remove(productId);
    _selectedIds.remove(productId); // Xóa khỏi selected set luôn
    notifyListeners();
  }

  /// 3. Giảm số lượng 1 đơn vị, nếu về 0 thì xóa
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
      _selectedIds.remove(productId);
    }
    notifyListeners();
  }

  /// 4. Tăng số lượng 1 đơn vị
  void addSingleItem(int productId) {
    if (!_items.containsKey(productId)) return;
    _items.update(
      productId,
      (existingItem) => CartItem(
        product: existingItem.product,
        quantity: existingItem.quantity + 1,
      ),
    );
    notifyListeners();
  }

  /// 5. Làm trống giỏ hàng (khi đặt hàng thành công)
  void clearCart() {
    _items.clear();
    _selectedIds.clear();
    notifyListeners();
  }

  // ─── Logic: Checkbox ──────────────────────────────────────────────────────

  /// 6. Toggle checkbox của một sản phẩm
  void toggleSelection(int productId) {
    if (_selectedIds.contains(productId)) {
      _selectedIds.remove(productId);
    } else {
      _selectedIds.add(productId);
    }
    notifyListeners();
  }

  /// 7. Chọn tất cả hoặc bỏ chọn tất cả
  void toggleSelectAll() {
    if (isAllSelected) {
      // Đang chọn tất cả → bỏ chọn tất
      _selectedIds.clear();
    } else {
      // Chưa chọn hết → chọn tất cả
      _selectedIds.addAll(_items.keys);
    }
    notifyListeners();
  }

  /// 8. Xóa tất cả các item đang được chọn
  void removeSelectedItems() {
    for (final id in _selectedIds.toList()) {
      _items.remove(id);
    }
    _selectedIds.clear();
    notifyListeners();
  }
}
