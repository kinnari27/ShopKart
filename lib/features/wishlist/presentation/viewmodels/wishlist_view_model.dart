import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_kart/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:shop_kart/injection/injection.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) => sl());

final wishlistViewModelProvider =
    NotifierProvider<WishlistViewModel, List<Product>>(WishlistViewModel.new);

class WishlistViewModel extends Notifier<List<Product>> {
  WishlistRepository get _repository => ref.read(wishlistRepositoryProvider);

  @override
  List<Product> build() => _repository.getItems();

  bool contains(int productId) => _repository.contains(productId);

  Future<void> toggle(Product product) async {
    await _repository.toggle(product);
    state = _repository.getItems();
  }
}
