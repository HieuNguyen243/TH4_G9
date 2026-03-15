import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Dữ liệu giả để test CartScreen
  static final List<ProductModel> _mockProducts = [
    ProductModel(
      id: 1,
      title: 'Áo thun nam basic',
      price: 19.99,
      description: 'Test sản phẩm 1',
      category: 'clothing',
      image:
          'https://fakestoreapi.com/img/81fAn-9N95L._AC_UY879_.jpg',
      rating: Rating(rate: 4.5, count: 100),
    ),
    ProductModel(
      id: 2,
      title: 'Quần jean slim fit',
      price: 55.99,
      description: 'Test sản phẩm 2',
      category: 'clothing',
      image:
          'https://fakestoreapi.com/img/71YXzeOuslL._AC_UY879_.jpg',
      rating: Rating(rate: 3.9, count: 200),
    ),
    ProductModel(
      id: 3,
      title: 'Giày sneaker trắng',
      price: 109.95,
      description: 'Test sản phẩm 3',
      category: 'shoes',
      image:
          'https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_FMwebp_QL65_.jpg',
      rating: Rating(rate: 4.8, count: 50),
    ),
    ProductModel(
      id: 4,
      title: 'Túi xách nữ cao cấp',
      price: 75.00,
      description: 'Test sản phẩm 4',
      category: 'bags',
      image:
          'https://fakestoreapi.com/img/81QpkIctqPL._AC_SX679_.jpg',
      rating: Rating(rate: 4.1, count: 320),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🧪 TEST - Giỏ Hàng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('(HomeScreen tạm thời)',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          // Icon giỏ hàng với badge
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.cart),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner hướng dẫn test
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.orange[50],
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bấm "+ Giỏ" rồi nhấn icon giỏ hàng để test CartScreen.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[800],
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách sản phẩm test
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _mockProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final product = _mockProducts[i];
                return _ProductTestCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget card sản phẩm cho bàn test
// ──────────────────────────────────────────────────────────────────────────────
class _ProductTestCard extends StatelessWidget {
  final ProductModel product;
  const _ProductTestCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final inCart = cart.items.containsKey(product.id);
    final qty = cart.items[product.id]?.quantity ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: inCart ? Colors.orange.withValues(alpha: 0.5) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.image,
              width: 65,
              height: 65,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 65,
                height: 65,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  product.formattedPrice,
                  style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Nút thêm vào giỏ + badge số lượng
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  cart.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Đã thêm "${product.title}"'),
                      duration: const Duration(milliseconds: 1200),
                      backgroundColor: Colors.green[600],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('+ Giỏ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (inCart)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Đã có: $qty',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
