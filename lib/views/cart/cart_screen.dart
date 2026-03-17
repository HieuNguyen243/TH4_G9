import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item_model.dart';
import '../../routes/app_routes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return _buildEmptyCart();
          }

          final cartItems = cart.items.values.toList();

          return Column(
            children: [
              // ── Thanh "Chọn tất cả" ───────────────────────────────────
              _buildSelectAllBar(context, cart),

              // ── Danh sách sản phẩm ────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    return _buildCartItemTile(context, cart, cartItem);
                  },
                ),
              ),

              // ── Thanh tổng tiền ở dưới đáy ────────────────────────────
              _buildBottomBar(context, cart),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      title: Consumer<CartProvider>(
        builder: (context, cart, _) => Text(
          'Giỏ hàng (${cart.totalQuantity})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        // Nút xóa các sản phẩm đã chọn
        Consumer<CartProvider>(
          builder: (context, cart, _) {
            if (cart.selectedItemCount == 0) return const SizedBox();
            return TextButton.icon(
              onPressed: () => _confirmDeleteSelected(context, cart),
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: Text(
                'Xóa (${cart.selectedItemCount})',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Thanh "Chọn tất cả"
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSelectAllBar(BuildContext context, CartProvider cart) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Checkbox "Chọn tất cả"
          Checkbox(
            value: cart.isAllSelected ? true : (cart.isIndeterminate ? null : false),
            tristate: true, // Cho phép trạng thái null (trung gian)
            activeColor: Colors.orange,
            onChanged: (_) => cart.toggleSelectAll(),
          ),
          GestureDetector(
            onTap: cart.toggleSelectAll,
            child: const Text(
              'Chọn tất cả',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const Spacer(),
          if (cart.selectedItemCount > 0)
            Text(
              'Đã chọn ${cart.selectedItemCount}/${cart.itemCount}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mỗi dòng sản phẩm trong giỏ hàng
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCartItemTile(
      BuildContext context, CartProvider cart, CartItem cartItem) {
    final product = cartItem.product;
    final isSelected = cart.isSelected(product.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(product.id),
        direction: DismissDirection.endToStart, // Vuốt trái để xóa
        background: _buildDismissBackground(),
        confirmDismiss: (_) => _confirmDismiss(context, product.title),
        onDismissed: (_) {
          cart.removeItem(product.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa "${product.title}"'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red[400],
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Checkbox ────────────────────────────────────────────
              Checkbox(
                value: isSelected,
                activeColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (_) => cart.toggleSelection(product.id),
              ),

              // ── Ảnh sản phẩm ────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.image,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── Thông tin sản phẩm ──────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Bộ điều chỉnh số lượng ─────────────────────
                      Row(
                        children: [
                          _quantityButton(
                            icon: Icons.remove,
                            onPressed: () =>
                                cart.removeSingleItem(product.id),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          _quantityButton(
                            icon: Icons.add,
                            onPressed: () => cart.addSingleItem(product.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quantityButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(icon, size: 16, color: Colors.grey[700]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Nền đỏ khi vuốt Dismissible
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text('Xóa',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Thanh tổng tiền & nút mua hàng ở đáy
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, CartProvider cart) {
    final total = cart.selectedTotalAmount;
    final selectedCount = cart.selectedItemCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ── Thông tin tổng tiền ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tổng thanh toán:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  if (selectedCount > 0)
                    Text(
                      '$selectedCount sản phẩm được chọn',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),

            // ── Nút Mua hàng ─────────────────────────────────────────
            ElevatedButton(
              onPressed: selectedCount == 0
                  ? null
                  : () {
                      Navigator.pushNamed(context, AppRoutes.checkout);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                selectedCount == 0
                    ? 'Mua hàng'
                    : 'Mua hàng ($selectedCount)',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Màn hình giỏ hàng trống
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng nhé!',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dialog xác nhận xóa khi vuốt Dismissible
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> _confirmDismiss(
      BuildContext context, String productTitle) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
                'Bạn có chắc muốn xóa "$productTitle" khỏi giỏ hàng?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style:
                    TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dialog xác nhận xóa các item đang chọn (từ AppBar)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _confirmDeleteSelected(
      BuildContext context, CartProvider cart) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm đã chọn'),
        content: Text(
            'Bạn có chắc muốn xóa ${cart.selectedItemCount} sản phẩm đã chọn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cart.removeSelectedItems();
    }
  }
}
