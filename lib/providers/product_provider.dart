import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  // 1. Biến trạng thái nội bộ (Private)
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // 2. Các Getter để UI có thể truy cập (Public)
  List<ProductModel> get products => [..._products]; // Trả về bản sao để bảo vệ dữ liệu gốc
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Đối tượng ApiService để gọi dữ liệu
  final ApiService _apiService = ApiService();

  // 3. Hàm chính: Lấy dữ liệu từ API và cập nhật trạng thái
  Future<void> fetchAndSetProducts() async {
    // Bắt đầu quá trình tải: bật loading, xóa lỗi cũ
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Thông báo cho UI để hiển thị Loading Spinner

    try {
      // Gọi Service để lấy dữ liệu
      final fetchedProducts = await _apiService.fetchAllProducts();
      
      // Gán dữ liệu vào biến trạng thái
      _products = fetchedProducts;
    } catch (error) {
      // Lưu thông báo lỗi nếu có
      _errorMessage = error.toString();
    } finally {
      // Kết thúc quá trình tải (dù thành công hay thất bại)
      _isLoading = false;
      notifyListeners(); // Thông báo cho UI để cập nhật danh sách hoặc hiển thị lỗi
    }
  }

  // TODO: Các thành viên khác có thể thêm logic lọc sản phẩm theo category tại đây
  // List<ProductModel> findByCategory(String categoryName) { ... }
}
