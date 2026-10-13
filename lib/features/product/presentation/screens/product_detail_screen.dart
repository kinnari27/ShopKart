import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_kart/core/widgets/shimmer_box.dart';
import 'package:shop_kart/features/cart/presentation/viewmodels/cart_view_model.dart';
import 'package:shop_kart/features/product/domain/usecases/get_product_detail.dart';
import 'package:shop_kart/features/wishlist/presentation/viewmodels/wishlist_view_model.dart';
import 'package:shop_kart/injection/injection.dart';

final getProductDetailUseCaseProvider =
    Provider<GetProductDetail>((ref) => sl());

final productDetailProvider = FutureProvider.family((ref, int id) {
  return ref.read(getProductDetailUseCaseProvider)(id);
});

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final isFavorite = ref.watch(
      wishlistViewModelProvider.select(
        (items) => items.any((item) => item.id == productId),
      ),
    );
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          productAsync.maybeWhen(
            data: (product) => IconButton(
              tooltip: isFavorite ? 'Remove from wishlist' : 'Add to wishlist',
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => ref
                  .read(wishlistViewModelProvider.notifier)
                  .toggle(product),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Cart',
            icon: cartCount > 0
                ? Badge.count(
                    count: cartCount,
                    child: const Icon(Icons.shopping_bag_outlined),
                  )
                : const Icon(Icons.shopping_bag_outlined),
            onPressed: () => context.push('/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            ShimmerBox(height: 320),
            SizedBox(height: 24),
            ShimmerBox(height: 20, width: 120),
            SizedBox(height: 12),
            ShimmerBox(height: 28),
            SizedBox(height: 16),
            ShimmerBox(height: 20, width: 200),
            SizedBox(height: 20),
            ShimmerBox(height: 80),
            SizedBox(height: 28),
            ShimmerBox(height: 48),
          ],
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 54,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load product',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(productDetailProvider(productId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
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
                  placeholder: (context, url) =>
                      const ShimmerBox(height: 320),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.category.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${product.rating} (${product.ratingCount} reviews)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () {
                ref.read(cartViewModelProvider.notifier).add(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Added to bag'),
                    action: SnackBarAction(
                      label: 'View Bag',
                      onPressed: () => context.push('/cart'),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Add to bag'),
            ),
          ],
        ),
      ),
    );
  }
}
