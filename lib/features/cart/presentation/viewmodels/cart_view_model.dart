import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_kart/features/cart/domain/entities/cart_item.dart';
import 'package:shop_kart/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_kart/injection/injection.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) => sl());

final cartViewModelProvider = NotifierProvider<CartViewModel, List<CartItem>>(
  CartViewModel.new,
);

class CartViewModel extends Notifier<List<CartItem>> {
  CartRepository get _repository => ref.read(cartRepositoryProvider);

  @override
  List<CartItem> build() => _repository.getItems();

  double get total => state.fold(0, (sum, item) => sum + item.total);

  Future<void> add(Product product) async {
    await _repository.add(product);
    state = _repository.getItems();
  }

  Future<void> remove(int productId) async {
    await _repository.remove(productId);
    state = _repository.getItems();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    await _repository.updateQuantity(productId, quantity);
    state = _repository.getItems();
  }
}
