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
    await _listBox.put('ids', products.map((product) => product.id).toList());
    for (final product in products) {
      await _productBox.put(product.id, product.toJson());
    }
  }

  Future<void> cacheCategories(List<String> categories) =>
      _listBox.put('categories', categories);

  List<ProductModel> getCachedProducts() {
    final ids = _listBox.get('ids', defaultValue: const <int>[]) ?? const [];
    final products = ids
        .map((id) => _productBox.get(id))
        .whereType<Map>()
        .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    if (products.isEmpty) {
      throw const CacheException('No cached products available.');
    }
    return products;
  }

  List<String> getCachedCategories() {
    final categories = _listBox.get('categories', defaultValue: const []);
    return categories?.cast<String>() ?? const [];
  }
}
