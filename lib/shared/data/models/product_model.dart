import 'package:shop_kart/shared/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.description,
    required super.category,
    required super.image,
    required super.rating,
    required super.ratingCount,
  });

  factory ProductModel.fromJson(Map<dynamic, dynamic> json) {
    final ratingRaw = json['rating'];
    final rating = ratingRaw is Map ? ratingRaw : const {};
    return ProductModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] as String? ?? '',
      rating: ((rating['rate'] ?? 0) as num).toDouble(),
      ratingCount: ((rating['count'] ?? 0) as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'image': image,
    'rating': {'rate': rating, 'count': ratingCount},
  };
}
