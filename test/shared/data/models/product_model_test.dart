import 'package:flutter_test/flutter_test.dart';
import 'package:shop_kart/shared/data/models/product_model.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

void main() {
  const tProductModel = ProductModel(
    id: 1,
    title: 'Test Product',
    price: 99.99,
    description: 'A great product for testing',
    category: 'electronics',
    image: 'https://example.com/image.png',
    rating: 4.5,
    ratingCount: 120,
  );

  final tJson = {
    'id': 1,
    'title': 'Test Product',
    'price': 99.99,
    'description': 'A great product for testing',
    'category': 'electronics',
    'image': 'https://example.com/image.png',
    'rating': {'rate': 4.5, 'count': 120},
  };

  test('ProductModel should be a subclass of Product entity', () {
    expect(tProductModel, isA<Product>());
  });

  test('fromJson should return a valid model from JSON map', () {
    final result = ProductModel.fromJson(tJson);
    expect(result, equals(tProductModel));
    expect(result.id, 1);
    expect(result.title, 'Test Product');
    expect(result.price, 99.99);
    expect(result.rating, 4.5);
    expect(result.ratingCount, 120);
  });

  test('toJson should return a JSON map with proper fields', () {
    final result = tProductModel.toJson();
    expect(result, equals(tJson));
  });

  test('fromJson should handle null rating gracefully', () {
    final jsonWithoutRating = Map<String, dynamic>.from(tJson)..remove('rating');
    final result = ProductModel.fromJson(jsonWithoutRating);
    expect(result.rating, 0.0);
    expect(result.ratingCount, 0);
  });

  test('fromJson should handle Map<dynamic, dynamic> rating from Hive', () {
    final Map<dynamic, dynamic> hiveRating = <dynamic, dynamic>{
      'rate': 4.8,
      'count': 95,
    };
    final jsonWithDynamicRating = <String, dynamic>{
      'id': 2,
      'title': 'Hive Item',
      'price': 49.99,
      'description': 'Item from Hive',
      'category': 'jewelery',
      'image': 'https://example.com/item.png',
      'rating': hiveRating,
    };
    final result = ProductModel.fromJson(jsonWithDynamicRating);
    expect(result.rating, 4.8);
    expect(result.ratingCount, 95);
  });
}
