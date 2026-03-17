import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order_model.dart';

class OrderService {
  static const String _ordersKey = 'orders';

  /// Lưu danh sách đơn hàng vào SharedPreferences
  static Future<void> saveOrders(List<Order> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = orders.map((order) => order.toJson()).toList();
      await prefs.setString(_ordersKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving orders: $e');
    }
  }

  /// Lấy danh sách đơn hàng từ SharedPreferences
  static Future<List<Order>> loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_ordersKey);
      
      if (jsonString == null) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  /// Xóa tất cả đơn hàng từ SharedPreferences
  static Future<void> clearAllOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ordersKey);
    } catch (e) {
      print('Error clearing orders: $e');
    }
  }
}
