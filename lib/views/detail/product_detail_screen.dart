import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  void _showAddToCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddToCartBottomSheet(product: widget.product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        backgroundColor: const Color(0xFFEE4D2D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_image_${widget.product.id}',
              child: Container(
                width: double.infinity,
                height: 350,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Image.network(
                  widget.product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.formattedPrice,
                    style: const TextStyle(
                      color: Color(0xFFEE4D2D),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _showAddToCartBottomSheet(context),
                child: Container(
                  color: const Color(0xFF00BFA5),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart, color: Colors.white),
                      Text('Thêm vào giỏ', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => _showAddToCartBottomSheet(context),
                child: Container(
                  color: const Color(0xFFEE4D2D),
                  child: const Center(
                    child: Text(
                      'Mua ngay',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartBottomSheet extends StatefulWidget {
  final ProductModel product;
  const _AddToCartBottomSheet({required this.product});

  @override
  State<_AddToCartBottomSheet> createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<_AddToCartBottomSheet> {
  String? selectedOption1; // Size cho quần áo, Phiên bản cho đồ điện tử
  String? selectedOption2; // Màu sắc cho cả hai
  int quantity = 1;

  late List<String> options1;
  late List<String> options2;
  late String label1;
  late String label2;

  @override
  void initState() {
    super.initState();
    // Phân loại dựa trên category
    String category = widget.product.category.toLowerCase();
    
    if (category.contains('clothing') || category.contains('men') || category.contains('women')) {
      // Nhóm Quần áo
      label1 = 'Kích cỡ (Size)';
      options1 = ['S', 'M', 'L', 'XL'];
      label2 = 'Màu sắc';
      options2 = ['Trắng', 'Đen', 'Xanh', 'Đỏ'];
    } else if (category.contains('electronics')) {
      // Nhóm Đồ điện tử
      label1 = 'Phiên bản (Dung lượng)';
      options1 = ['128GB', '256GB', '512GB', '1TB'];
      label2 = 'Màu sắc thiết bị';
      options2 = ['Bạc (Silver)', 'Xám (Space Gray)', 'Vàng (Gold)', 'Xanh'];
    } else {
      // Mặc định (cho các loại khác như túi xách, giày dép...)
      label1 = 'Tùy chọn';
      options1 = ['Tiêu chuẩn'];
      label2 = 'Màu sắc';
      options2 = ['Mặc định'];
    }
    
    selectedOption1 = options1[0];
    selectedOption2 = options2[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(
                widget.product.image,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.formattedPrice, 
                    style: const TextStyle(color: Color(0xFFEE4D2D), fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Kho: 999', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          
          // Lựa chọn 1 (Size hoặc Dung lượng)
          Text(label1, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options1.map((opt) => ChoiceChip(
              label: Text(opt),
              selected: selectedOption1 == opt,
              onSelected: (_) => setState(() => selectedOption1 = opt),
              selectedColor: const Color(0xFFEE4D2D).withOpacity(0.1),
              labelStyle: TextStyle(color: selectedOption1 == opt ? const Color(0xFFEE4D2D) : Colors.black),
              showCheckmark: false,
            )).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Lựa chọn 2 (Màu sắc)
          Text(label2, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options2.map((opt) => ChoiceChip(
              label: Text(opt),
              selected: selectedOption2 == opt,
              onSelected: (_) => setState(() => selectedOption2 = opt),
              selectedColor: const Color(0xFFEE4D2D).withOpacity(0.1),
              labelStyle: TextStyle(color: selectedOption2 == opt ? const Color(0xFFEE4D2D) : Colors.black),
              showCheckmark: false,
            )).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Số lượng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Số lượng', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(onPressed: quantity > 1 ? () => setState(() => quantity--) : null, icon: const Icon(Icons.remove)),
                  Text('$quantity', style: const TextStyle(fontSize: 18)),
                  IconButton(onPressed: () => setState(() => quantity++), icon: const Icon(Icons.add)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Nút xác nhận
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE4D2D),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                context.read<CartProvider>().addToCart(widget.product, quantity: quantity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm $quantity x ${widget.product.title} ($selectedOption1, $selectedOption2) vào giỏ!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
