// lib/models/product_model.dart

class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  // Factory method để tạo một ProductModel từ dữ liệu JSON nhận được từ API
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
      rating: Rating.fromJson(json['rating']),
    );
  }

  // Chuyển đổi một ProductModel thành JSON (dùng khi gửi dữ liệu lên API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating.toJson(),
    };
  }

  // Hàm định dạng giá tiền (Ví dụ: 100.0 -> $100.0)
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  // Thuộc tính bổ sung cho Shopee UI (Yêu thích - giả lập logic)
  bool get isFavorite => id % 2 == 0;

  // Thuộc tính bổ sung: Số lượng đã bán (giả lập logic)
  int get soldCount => (id * 15) % 1000;
}

class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: (json['rate'] as num).toDouble(),
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'count': count,
    };
  }
}
