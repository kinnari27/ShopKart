import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_kart/core/widgets/app_empty_state.dart';
import 'package:shop_kart/features/product/presentation/widgets/product_card.dart';
import 'package:shop_kart/features/wishlist/presentation/viewmodels/wishlist_view_model.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(wishlistViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: products.isEmpty
          ? const AppEmptyState(
              title: 'No favorites yet',
              message: 'Tap the heart on a product to save it.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .68,
              ),
              itemCount: products.length,
              itemBuilder: (_, index) => ProductCard(product: products[index]),
            ),
    );
  }
}
