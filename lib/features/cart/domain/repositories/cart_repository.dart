import 'package:shop_kart/features/cart/domain/entities/cart_item.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

abstract interface class CartRepository {
  List<CartItem> getItems();

  Future<void> add(Product product);

  Future<void> remove(int productId);

  Future<void> updateQuantity(int productId, int quantity);

  Future<void> clear();
}
