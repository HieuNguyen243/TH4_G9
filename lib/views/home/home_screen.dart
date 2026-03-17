import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi API khi màn hình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAndSetProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFEE4D2D)));
          }

          if (productProvider.errorMessage.isNotEmpty) {
            return Center(child: Text('Lỗi: ${productProvider.errorMessage}'));
          }

          return CustomScrollView(
            slivers: [
              // 1. SliverAppBar với Search Bar dính trên Top
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                pinned: true,
                backgroundColor: const Color(0xFFEE4D2D),
                title: const Text('Shopee Clone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                actions: [
                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      return Badge(
                        label: Text('${cart.totalQuantity}'),
                        isLabelVisible: cart.totalQuantity > 0,
                        backgroundColor: Colors.white,
                        textColor: const Color(0xFFEE4D2D),
                        child: IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, size: 26, color: Colors.white),
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFEE4D2D), Color(0xFFFF7337)],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.search, color: Color(0xFFEE4D2D)),
                          ),
                          Text('Tìm kiếm trên Shopee', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Banner quảng cáo
              SliverToBoxAdapter(
                child: Container(
                  height: 180,
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Siêu Sale 12.12', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Giảm giá lên đến 50%', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),

              // Danh mục hoặc Tiêu đề danh sách
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('GỢI Ý HÔM NAY', style: TextStyle(color: Color(0xFFEE4D2D), fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              // 3. GridView 2 cột hiển thị sản phẩm
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ProductCard(product: productProvider.products[index]);
                    },
                    childCount: productProvider.products.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }
}
