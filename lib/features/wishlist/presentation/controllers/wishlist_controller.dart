import 'package:get/get.dart';
import 'package:shop_kart/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:shop_kart/injection/injection.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class WishlistController extends GetxController {
  static WishlistController get to => Get.find();

  final WishlistRepository _repository;

  WishlistController({WishlistRepository? repository})
      : _repository = repository ?? sl<WishlistRepository>() {
    loadItems();
  }

  final RxList<Product> items = <Product>[].obs;

  void loadItems() {
    items.assignAll(_repository.getItems());
  }

  bool contains(int productId) => items.any((item) => item.id == productId);

  Future<void> toggle(Product product) async {
    await _repository.toggle(product);
    items.assignAll(_repository.getItems());
  }
}
