import 'package:hive/hive.dart';
import 'package:shop_kart/core/errors/app_exception.dart';
import 'package:shop_kart/shared/data/models/product_model.dart';

class ProductLocalDataSource {
  ProductLocalDataSource({
    required Box<Map> productBox,
    required Box<List> listBox,
  }) : _productBox = productBox,
       _listBox = listBox;

  final Box<Map> _productBox;
  final Box<List> _listBox;

  Future<void> cacheProducts(List<ProductModel> products) async {
    final rawIds = _listBox.get('ids', defaultValue: const <dynamic>[]) ?? const [];
    final existingIds = rawIds.map((e) => e as int).toSet();
    existingIds.addAll(products.map((product) => product.id));
    await _listBox.put('ids', existingIds.toList());
    for (final product in products) {
      await _productBox.put(product.id, product.toJson());
    }
  }

  Future<void> cacheCategories(List<String> categories) =>
      _listBox.put('categories', categories);

  List<ProductModel> getCachedProducts({String? category}) {
    final rawIds = _listBox.get('ids', defaultValue: const <dynamic>[]) ?? const [];
    final ids = rawIds.map((e) => e as int).toList();
    final products = ids
        .map((id) => _productBox.get(id))
        .whereType<Map>()
        .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    if (products.isEmpty) {
      throw const CacheException('No cached products available.');
    }
    if (category != null && category != 'All') {
      final filtered = products
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
      if (filtered.isEmpty) {
        throw CacheException('No cached products available for category: $category');
      }
      return filtered;
    }
    return products;
  }

  List<String> getCachedCategories() {
    final categories = _listBox.get('categories', defaultValue: const []);
    return categories?.cast<String>() ?? const [];
  }
}
