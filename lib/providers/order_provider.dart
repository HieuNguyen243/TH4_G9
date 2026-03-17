import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  List<Order> get pendingOrders =>
      _orders.where((order) => order.status == 'pending').toList();

  List<Order> get shippingOrders =>
      _orders.where((order) => order.status == 'shipping').toList();

  List<Order> get deliveredOrders =>
      _orders.where((order) => order.status == 'delivered').toList();

  /// Thêm đơn hàng mới
  void addOrder(Order order) {
    _orders.insert(0, order); // Thêm vào đầu danh sách
    notifyListeners();
  }

  /// Cập nhật trạng thái đơn hàng
  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _orders[index] = Order(
        id: _orders[index].id,
        items: _orders[index].items,
        totalAmount: _orders[index].totalAmount,
        address: _orders[index].address,
        paymentMethod: _orders[index].paymentMethod,
        status: newStatus,
        createdAt: _orders[index].createdAt,
      );
      notifyListeners();
    }
  }

  /// Chuyển đổi orders thành JSON
  List<Map<String, dynamic>> toJson() {
    return _orders.map((order) => order.toJson()).toList();
  }

  /// Khôi phục orders từ JSON
  void fromJson(List<dynamic> jsonList) {
    _orders = (jsonList as List)
        .map((json) => Order.fromJson(json as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  /// Xóa đơn hàng
  void removeOrder(String orderId) {
    _orders.removeWhere((order) => order.id == orderId);
    notifyListeners();
  }

  /// Xóa tất cả đơn hàng
  void clearAllOrders() {
    _orders.clear();
    notifyListeners();
  }
}
