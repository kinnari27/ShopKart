import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/widgets/app_empty_state.dart';
import 'package:shop_kart/features/product/presentation/widgets/product_card.dart';
import 'package:shop_kart/features/wishlist/presentation/controllers/wishlist_controller.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WishlistController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: Obx(() {
        final products = controller.items;

        if (products.isEmpty) {
          return const AppEmptyState(
            title: 'No favorites yet',
            message: 'Tap the heart on a product to save it.',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: .68,
          ),
          itemCount: products.length,
          itemBuilder: (_, index) => ProductCard(product: products[index]),
        );
      }),
    );
  }
}
