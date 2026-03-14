import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/constants.dart';

class ApiService {
  // Hàm lấy toàn bộ sản phẩm từ API (FakeStoreAPI)
  Future<List<ProductModel>> fetchAllProducts() async {
    try {
      // 1. URL của API endpoint (https://fakestoreapi.com/products)
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.productsEndpoint}');

      // 2. Thực hiện gọi HTTP GET
      final response = await http.get(url);

      // 3. Kiểm tra mã trạng thái trả về (200 là thành công)
      if (response.statusCode == 200) {
        // 4. Giải mã body JSON (trả về một List dynamic)
        final List<dynamic> body = json.decode(response.body);

        // 5. Chuyển đổi từng phần tử JSON sang ProductModel bằng factory fromJson
        final List<ProductModel> products = body
            .map((dynamic item) => ProductModel.fromJson(item))
            .toList();

        return products;
      } else {
        // Lỗi từ phía API server (ví dụ: 404, 500)
        throw Exception('Lỗi API: Mã lỗi ${response.statusCode}');
      }
    } catch (error) {
      // Xử lý các trường hợp lỗi kết nối, Timeout hoặc giải mã JSON lỗi
      print('Lỗi ApiService: $error');
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra internet!');
    }
  }

  // TODO: Các thành viên khác có thể thêm hàm lấy sản phẩm theo danh mục (category) tại đây
  // Ví dụ: fetchProductsByCategory(String category)...
}
