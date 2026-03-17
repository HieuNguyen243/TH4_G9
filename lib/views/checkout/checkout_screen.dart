import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../providers/cart_provider.dart';
import '../../models/cart_item_model.dart';
import '../../routes/app_routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late TextEditingController _addressController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String _selectedPaymentMethod = 'COD'; // Default là COD

  late List<CartItem> _selectedItems;
  late double _totalAmount;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    // Lấy danh sách sản phẩm đã tick từ CartProvider
    final cartProvider = context.read<CartProvider>();
    _selectedItems = cartProvider.items.entries
        .where((entry) => cartProvider.isSelected(entry.key))
        .map((entry) => entry.value)
        .toList();
    _totalAmount = cartProvider.selectedTotalAmount;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    // Validate input
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin và chọn sản phẩm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tạo dữ liệu đơn hàng dưới dạng Map
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final newOrder = {
      'id': orderId,
      'items': _selectedItems.map((item) => {
        'productId': item.product.id,
        'title': item.product.title,
        'price': item.product.price,
        'quantity': item.quantity,
        'image': item.product.image,
      }).toList(),
      'totalAmount': _totalAmount,
      'address': _addressController.text,
      'paymentMethod': _selectedPaymentMethod,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Lưu vào SharedPreferences
    _saveOrderToPreferences(newOrder);

    // Xóa giỏ hàng
    context.read<CartProvider>().clearCart();

    // Hiển thị dialog thành công
    _showSuccessDialog();
  }

  Future<void> _saveOrderToPreferences(Map<String, dynamic> order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('orders') ?? '[]';
      final orders = jsonDecode(ordersJson) as List;
      orders.add(order);
      await prefs.setString('orders', jsonEncode(orders));
    } catch (e) {
      print('Error saving order: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đặt hàng thành công!'),
        content: const Text('Đơn hàng của bạn đã được tiếp nhận. Vui lòng chờ xác nhận.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Đóng dialog
              // Đá về trang chủ - xóa toàn bộ navigation stack
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
            },
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: _selectedItems.isEmpty
          ? const Center(child: Text('Không có sản phẩm nào để thanh toán'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Phần Thông tin sản phẩm ────────────────────────────
                  const Text(
                    'Sản phẩm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedItems.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 0, color: Colors.grey.shade300),
                      itemBuilder: (context, index) {
                        final item = _selectedItems[index];
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                item.product.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Giá: ${item.product.formattedPrice}',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Số lượng: ${item.quantity}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Phần Thông tin giao hàng ────────────────────────────
                  const Text(
                    'Thông tin giao hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Họ và tên',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Số điện thoại',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Địa chỉ giao hàng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // ─── Phần Phương thức thanh toán ──────────────────────────
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('COD (Thanh toán khi nhận hàng)'),
                          value: 'COD',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            }
                          },
                        ),
                        Divider(height: 0, color: Colors.grey.shade300),
                        RadioListTile<String>(
                          title: const Text('Momo (Ví điện tử)'),
                          value: 'Momo',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Phần Tổng cộng ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Nút Đặt hàng ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Đặt hàng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
