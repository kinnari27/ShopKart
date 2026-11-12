import 'package:get/get.dart';
import 'package:shop_kart/features/cart/domain/entities/cart_item.dart';
import 'package:shop_kart/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_kart/injection/injection.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class CartController extends GetxController {
  static CartController get to => Get.find();

  final CartRepository _repository;

  CartController({CartRepository? repository})
      : _repository = repository ?? sl<CartRepository>() {
    loadItems();
  }

  final RxList<CartItem> items = <CartItem>[].obs;

  double get total => items.fold(0.0, (sum, item) => sum + item.total);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  void loadItems() {
    items.assignAll(_repository.getItems());
  }

  Future<void> add(Product product) async {
    await _repository.add(product);
    items.assignAll(_repository.getItems());
  }

  Future<void> remove(int productId) async {
    await _repository.remove(productId);
    items.assignAll(_repository.getItems());
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    await _repository.updateQuantity(productId, quantity);
    items.assignAll(_repository.getItems());
  }

  Future<void> clear() async {
    await _repository.clear();
    items.assignAll(_repository.getItems());
  }
}
