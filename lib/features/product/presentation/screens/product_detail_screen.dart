import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/routing/app_routes.dart';
import 'package:shop_kart/core/widgets/shimmer_box.dart';
import 'package:shop_kart/features/cart/presentation/controllers/cart_controller.dart';
import 'package:shop_kart/features/product/presentation/controllers/product_detail_controller.dart';
import 'package:shop_kart/features/wishlist/presentation/controllers/wishlist_controller.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context) {
    final detailController = Get.put(
      ProductDetailController(productId: productId),
      tag: '$productId',
    );
    final wishlistController = Get.find<WishlistController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Obx(() {
            final product = detailController.product.value;
            if (product == null) return const SizedBox.shrink();

            final isFavorite = wishlistController.contains(productId);
            return IconButton(
              tooltip: isFavorite ? 'Remove from wishlist' : 'Add to wishlist',
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => wishlistController.toggle(product),
            );
          }),
          Obx(() {
            final count = cartController.itemCount;
            return IconButton(
              tooltip: 'Cart',
              icon: count > 0
                  ? Badge.count(
                      count: count,
                      child: const Icon(Icons.shopping_bag_outlined),
                    )
                  : const Icon(Icons.shopping_bag_outlined),
              onPressed: () => Get.toNamed(AppRoutes.cart),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (detailController.isLoading.value) {
          return ListView(
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
          );
        }

        final error = detailController.errorMessage.value;
        if (error != null) {
          return Center(
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
                    error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => detailController.loadProduct(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final product = detailController.product.value;
        if (product == null) {
          return const Center(child: Text('Product not found'));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Hero(
              tag: 'product-${product.id}',
              child: SizedBox(
                height: 320,
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const ShimmerBox(height: 320),
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
                cartController.add(product);
                Get.snackbar(
                  'Added to bag',
                  product.title,
                  snackPosition: SnackPosition.BOTTOM,
                  mainButton: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.cart),
                    child: const Text('View Bag'),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Add to bag'),
            ),
          ],
        );
      }),
    );
  }
}
