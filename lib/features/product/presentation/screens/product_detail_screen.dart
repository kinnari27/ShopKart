import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/routing/app_routes.dart';
import 'package:shop_kart/core/widgets/shimmer_box.dart';
import 'package:shop_kart/features/cart/presentation/controllers/cart_controller.dart';
import 'package:shop_kart/features/product/presentation/controllers/product_detail_controller.dart';
import 'package:shop_kart/features/review/presentation/widgets/review_sheet.dart';
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
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => ReviewSheet.showReviews(
                    context,
                    detailController,
                    product,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Obx(() {
                          final p = detailController.product.value ?? product;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${p.rating}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${p.ratingCount} reviews)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
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
            if (product.isClothing) ...[
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Size',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Obx(
                    () => Text(
                      'Size: ${detailController.selectedSize.value}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(
                () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: product.availableSizes.map((size) {
                      final isSelected =
                          detailController.selectedSize.value == size;
                      final colors = Theme.of(context).colorScheme;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () => detailController.selectSize(size),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary
                                  : colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : colors.outlineVariant.withAlpha(80),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected
                                    ? colors.onPrimary
                                    : colors.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final product = detailController.product.value;
        if (product == null || detailController.isLoading.value) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final size = product.isClothing
                  ? detailController.selectedSize.value
                  : null;
              cartController.add(product, size: size);
              Get.snackbar(
                'Added to bag',
                size != null
                    ? '${product.title} (Size: $size)'
                    : product.title,
                snackPosition: SnackPosition.BOTTOM,
                mainButton: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.cart),
                  child: const Text('View Bag'),
                ),
              );
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text(
              'Add to bag',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }
}
