import 'package:shop_kart/shared/domain/entities/product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> getProducts({String? category});

  Future<Product> getProduct(int id);

  Future<List<String>> getCategories();
}
