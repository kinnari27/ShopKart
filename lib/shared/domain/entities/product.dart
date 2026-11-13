import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  bool get isClothing =>
      category.toLowerCase().contains('clothing') ||
      category.toLowerCase().contains('cloth') ||
      category.toLowerCase().contains('shirt') ||
      category.toLowerCase().contains('jacket');

  List<String> get availableSizes => const ['S', 'M', 'L', 'XL', 'XXL'];

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
    double? rating,
    int? ratingCount,
  }) => Product(
    id: id ?? this.id,
    title: title ?? this.title,
    price: price ?? this.price,
    description: description ?? this.description,
    category: category ?? this.category,
    image: image ?? this.image,
    rating: rating ?? this.rating,
    ratingCount: ratingCount ?? this.ratingCount,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    price,
    description,
    category,
    image,
    rating,
    ratingCount,
  ];
}
