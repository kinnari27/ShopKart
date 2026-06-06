import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_kart/core/widgets/app_empty_state.dart';
import 'package:shop_kart/features/cart/presentation/viewmodels/cart_view_model.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartViewModelProvider);
    final total = ref.read(cartViewModelProvider.notifier).total;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: items.isEmpty
          ? const AppEmptyState(
              title: 'Your cart is empty',
              message: 'Products you add will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
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
                  subtitle: Text('\$${item.product.price.toStringAsFixed(2)}'),
                  trailing: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => ref
                            .read(cartViewModelProvider.notifier)
                            .updateQuantity(item.product.id, item.quantity - 1),
                        icon: const Icon(Icons.remove),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        onPressed: () => ref
                            .read(cartViewModelProvider.notifier)
                            .updateQuantity(item.product.id, item.quantity + 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () {},
                child: Text('Checkout - \$${total.toStringAsFixed(2)}'),
              ),
            ),
    );
  }
}
