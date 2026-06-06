import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_kart/features/cart/presentation/viewmodels/cart_view_model.dart';
import 'package:shop_kart/features/home/presentation/viewmodels/product_list_view_model.dart';

final productDetailProvider = FutureProvider.family((ref, int id) {
  return ref.read(productRepositoryProvider).getProduct(id);
});

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(),
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (product) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Hero(
              tag: 'product-${product.id}',
              child: SizedBox(
                height: 320,
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.category.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star_rounded),
                Text('${product.rating} (${product.ratingCount})'),
                const Spacer(),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(product.description),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () {
                ref.read(cartViewModelProvider.notifier).add(product);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Added to cart')));
              },
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Add to cart'),
            ),
          ],
        ),
      ),
    );
  }
}
