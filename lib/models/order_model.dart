import 'cart_item_model.dart';
import 'product_model.dart';

class Order {
  final String id; // ID đơn hàng (UUID hoặc timestamp)
  final List<CartItem> items; // Các sản phẩm trong đơn
  final double totalAmount; // Tổng tiền
  final String address; // Địa chỉ giao hàng
  final String paymentMethod; // Phương thức thanh toán (Momo/COD)
  final String status; // Trạng thái: "pending" (Chờ xác nhận), "shipping" (Đang giao), "delivered" (Đã giao)
  final DateTime createdAt; // Thời gian tạo đơn

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  // Chuyển đổi Order thành JSON để lưu vào SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => {
        'productId': item.product.id,
        'title': item.product.title,
        'price': item.product.price,
        'quantity': item.quantity,
        'image': item.product.image,
      }).toList(),
      'totalAmount': totalAmount,
      'address': address,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Tạo Order từ JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List).map((item) {
        // Tái tạo CartItem từ JSON
        return CartItem(
          product: _createProductFromOrderJson(item),
          quantity: item['quantity'],
        );
      }).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      address: json['address'],
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Helper function để tạo ProductModel từ order JSON (thông tin tối thiểu)
  static _createProductFromOrderJson(Map<String, dynamic> item) {
    // Import ProductModel từ product_model.dart nếu cần đầy đủ
    // Ở đây chỉ lưu trữ thông tin cơ bản
    final emptyRating = Rating(rate: 0.0, count: 0);
    return ProductModel(
      id: item['productId'],
      title: item['title'],
      price: (item['price'] as num).toDouble(),
      description: '',
      category: '',
      image: item['image'],
      rating: emptyRating,
    );
  }

  // Lấy tên trạng thái hiển thị cho UI
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      default:
        return 'Không xác định';
    }
  }

  // Lấy màu sắc cho status
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'shipping':
        return '#4169E1'; // Blue
      case 'delivered':
        return '#28A745'; // Green
      default:
        return '#999999'; // Gray
    }
  }
}
