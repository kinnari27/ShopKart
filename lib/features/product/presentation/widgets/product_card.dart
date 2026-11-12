import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/routing/app_routes.dart';
import 'package:shop_kart/core/widgets/shimmer_box.dart';
import 'package:shop_kart/features/wishlist/presentation/controllers/wishlist_controller.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.product(product.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Hero(
                      tag: 'product-${product.id}',
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: product.image,
                          fit: BoxFit.contain,
                          placeholder: (context, url) =>
                              const ShimmerBox(height: double.infinity),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color: colors.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Obx(() {
                        final isFavorite =
                            wishlistController.contains(product.id);
                        return IconButton.filledTonal(
                          tooltip: 'Wishlist',
                          onPressed: () => wishlistController.toggle(product),
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 18, color: colors.tertiary),
                  Text(product.rating.toStringAsFixed(1)),
                  const Spacer(),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
