import 'package:hive/hive.dart';
import 'package:shop_kart/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:shop_kart/shared/data/models/product_model.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._box);

  final Box<Map> _box;

  @override
  List<Product> getItems() => _box.values
      .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
      .toList();

  @override
  bool contains(int productId) => _box.containsKey(productId);

  @override
  Future<void> toggle(Product product) async {
    if (contains(product.id)) {
      await _box.delete(product.id);
      return;
    }
    await _box.put(product.id, {
      'id': product.id,
      'title': product.title,
      'price': product.price,
      'description': product.description,
      'category': product.category,
      'image': product.image,
      'rating': {'rate': product.rating, 'count': product.ratingCount},
    });
  }
}
