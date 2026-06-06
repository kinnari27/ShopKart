import 'package:hive/hive.dart';
import 'package:shop_kart/features/cart/domain/entities/cart_item.dart';
import 'package:shop_kart/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_kart/shared/data/models/product_model.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._box);

  final Box<Map> _box;

  @override
  List<CartItem> getItems() => _box.values.map((json) {
    final map = Map<String, dynamic>.from(json);
    return CartItem(
      product: ProductModel.fromJson(
        Map<String, dynamic>.from(map['product'] as Map),
      ),
      quantity: map['quantity'] as int,
    );
  }).toList();

  @override
  Future<void> add(Product product) async {
    final existing = _box.get(product.id);
    final quantity = existing == null
        ? 1
        : (Map<String, dynamic>.from(existing)['quantity'] as int) + 1;
    await _box.put(product.id, {
      'product': _toMap(product),
      'quantity': quantity,
    });
  }

  @override
  Future<void> remove(int productId) => _box.delete(productId);

  @override
  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) return remove(productId);
    final existing = _box.get(productId);
    if (existing == null) return;
    final map = Map<String, dynamic>.from(existing);
    await _box.put(productId, {...map, 'quantity': quantity});
  }

  @override
  Future<void> clear() => _box.clear();

  Map<String, dynamic> _toMap(Product product) => {
    'id': product.id,
    'title': product.title,
    'price': product.price,
    'description': product.description,
    'category': product.category,
    'image': product.image,
    'rating': {'rate': product.rating, 'count': product.ratingCount},
  };
}
