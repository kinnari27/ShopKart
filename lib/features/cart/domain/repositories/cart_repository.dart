import 'package:shop_kart/features/cart/domain/entities/cart_item.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

abstract interface class CartRepository {
  List<CartItem> getItems();

  Future<void> add(Product product, {String? size});

  Future<void> remove(dynamic productId);

  Future<void> updateQuantity(dynamic productId, int quantity);

  Future<void> clear();
}
