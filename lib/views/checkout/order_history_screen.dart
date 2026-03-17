import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  Future<List<Map<String, dynamic>>> _loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('orders') ?? '[]';
      final orders = jsonDecode(ordersJson) as List;
      return orders.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn mua'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = snapshot.data ?? [];

            return TabBarView(
              children: [
                _buildOrderTab(orders, 'pending'),
                _buildOrderTab(orders, 'shipping'),
                _buildOrderTab(orders, 'delivered'),
                _buildOrderTab(orders, 'cancelled'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderTab(List<Map<String, dynamic>> allOrders, String status) {
    final orders = allOrders.where((order) => order['status'] == status).toList();

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có đơn hàng nào',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final status = order['status'] as String;
    final statusColor = _getStatusColor(status);
    final statusName = _getStatusName(status);
    final items = (order['items'] as List?) ?? [];
    final totalAmount = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final address = order['address'] as String? ?? '';
    final paymentMethod = order['paymentMethod'] as String? ?? '';
    final createdAt = DateTime.parse(order['createdAt'] as String? ?? DateTime.now().toIso8601String());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID và trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn #${(order['id'] as String).substring(0, 6)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Danh sách sản phẩm
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sản phẩm (${items.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...items.take(2).map((item) {
                    final title = item['title'] as String? ?? '';
                    final quantity = item['quantity'] as int? ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $title x$quantity',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }),
                  if (items.length > 2)
                    Text(
                      '• +${items.length - 2} sản phẩm khác',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Thông tin giao hàng
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Phương thức thanh toán
            Row(
              children: [
                Icon(Icons.payment_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  paymentMethod,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Footer: Ngày tạo và tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ngày: ${_formatDate(createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nút "Chi tiết"
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showOrderDetails(context, order),
                child: const Text('Xem chi tiết'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    final items = (order['items'] as List?) ?? [];
    final totalAmount = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final address = order['address'] as String? ?? '';
    final paymentMethod = order['paymentMethod'] as String? ?? '';
    final createdAt = DateTime.parse(order['createdAt'] as String? ?? DateTime.now().toIso8601String());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết đơn hàng'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sản phẩm:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...items.map((item) {
                final title = item['title'] as String? ?? '';
                final quantity = item['quantity'] as int? ?? 0;
                final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                final itemTotal = price * quantity;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '• $title x$quantity - \$${itemTotal.toStringAsFixed(2)}',
                  ),
                );
              }),
              const SizedBox(height: 16),
              Text(
                'Địa chỉ: $address',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Thanh toán: $paymentMethod'),
              const SizedBox(height: 8),
              Text('Ngày tạo: ${_formatDate(createdAt)}'),
              const SizedBox(height: 16),
              Text(
                'Tổng: \$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'shipping':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusName(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
