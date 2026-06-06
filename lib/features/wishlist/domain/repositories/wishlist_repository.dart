import 'package:shop_kart/shared/domain/entities/product.dart';

abstract interface class WishlistRepository {
  List<Product> getItems();

  bool contains(int productId);

  Future<void> toggle(Product product);
}
