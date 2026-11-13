import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/routing/app_routes.dart';
import 'package:shop_kart/core/widgets/app_empty_state.dart';
import 'package:shop_kart/features/cart/presentation/controllers/cart_controller.dart';
import 'package:shop_kart/features/order/presentation/controllers/order_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _showCheckoutDialog(BuildContext context, CartController controller) {
    final total = controller.total;
    final count = controller.itemCount;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Order Summary',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items ($count)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'FREE',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  final orderController = Get.find<OrderController>();
                  final order = await orderController.placeOrder(
                    items: controller.items.toList(),
                    total: total,
                  );
                  await controller.clear();
                  if (context.mounted) {
                    Navigator.of(bottomSheetContext).pop();
                  }
                  Get.toNamed(AppRoutes.orderTracking, arguments: order.id);
                  Get.snackbar(
                    'Order Placed! 🎉',
                    'Order #${order.id} placed successfully. You can track delivery status below.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm & Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Obx(() {
      final items = controller.items;
      final total = controller.total;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          actions: [
            if (items.isNotEmpty)
              IconButton(
                tooltip: 'Clear cart',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => controller.clear(),
              ),
          ],
        ),
        body: items.isEmpty
            ? const AppEmptyState(
                title: 'Your cart is empty',
                message: 'Products you add will appear here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Dismissible(
                    key: ValueKey('cart_item_${item.cartKey}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    onDismissed: (_) {
                      controller.remove(item.cartKey);
                    },
                    child: ListTile(
                      tileColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: CachedNetworkImage(
                        imageUrl: item.product.image,
                        width: 48,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        item.product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          Text('\$${item.product.price.toStringAsFixed(2)}'),
                          if (item.size != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Size: ${item.size}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => controller.updateQuantity(
                              item.cartKey,
                              item.quantity - 1,
                            ),
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            onPressed: () => controller.updateQuantity(
                              item.cartKey,
                              item.quantity + 1,
                            ),
                            icon: const Icon(Icons.add_circle_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: items.isEmpty
            ? null
            : SafeArea(
                minimum: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => _showCheckoutDialog(context, controller),
                  child: Text('Checkout - \$${total.toStringAsFixed(2)}'),
                ),
              ),
      );
    });
  }
}
