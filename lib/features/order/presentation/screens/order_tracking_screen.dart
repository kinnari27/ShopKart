import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/controllers/dashboard_controller.dart';
import 'package:shop_kart/core/routing/app_routes.dart';
import 'package:shop_kart/features/order/domain/entities/order_entity.dart';
import 'package:shop_kart/features/order/presentation/controllers/order_controller.dart';
import 'package:shop_kart/features/order/presentation/widgets/order_timeline.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String? orderId;

  const OrderTrackingScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();
    final targetId = orderId ?? (Get.arguments as String?) ?? Get.parameters['id'];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAllNamed(AppRoutes.dashboard);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'All Orders',
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () => Get.toNamed(AppRoutes.orders),
          ),
        ],
      ),
      body: Obx(() {
        final order = controller.orders.firstWhereOrNull((o) => o.id == targetId) ??
            controller.currentOrder.value;

        if (order == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Order not found',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Success / Status Banner
              _buildHeaderBanner(context, order),
              const SizedBox(height: 16),

              // Tracking Stepper Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tracking Status',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildStatusBadge(context, order.status),
                        ],
                      ),
                      const SizedBox(height: 20),
                      OrderTimeline(order: order),

                      // Advance Tracking / Cancel Actions (for demo & interactivity)
                      if (order.status != OrderStatus.delivered &&
                          order.status != OrderStatus.cancelled) ...[
                        const Divider(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => controller.advanceStatus(order.id),
                                icon: const Icon(Icons.fast_forward_rounded, size: 18),
                                label: const Text('Advance Status (Demo)'),
                              ),
                            ),
                            if (order.status == OrderStatus.placed ||
                                order.status == OrderStatus.confirmed) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Cancel Order',
                                icon: Icon(
                                  Icons.cancel_outlined,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () => _confirmCancelDialog(context, controller, order.id),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Address Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Address',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.deliveryAddress,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Items Ordered List
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items in this Order (${order.totalItemCount})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: item.image,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.contain,
                                    errorWidget: (context, url, error) => const Icon(Icons.image),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            'Qty: ${item.quantity}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.outline,
                                            ),
                                          ),
                                          if (item.size != null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.secondaryContainer,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Size: ${item.size}',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.onSecondaryContainer,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${item.total.toStringAsFixed(2)}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment & Total Summary
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment Method', style: theme.textTheme.bodyMedium),
                          Text(order.paymentMethod, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery', style: theme.textTheme.bodyMedium),
                          Text('FREE', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Paid', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Back to shopping button
              FilledButton.icon(
                onPressed: () {
                  final dashboardController = Get.isRegistered<DashboardController>()
                      ? Get.find<DashboardController>()
                      : null;
                  dashboardController?.changeTab(0);
                  Get.offAllNamed(AppRoutes.dashboard);
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Continue Shopping'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.orders),
                icon: const Icon(Icons.receipt_outlined),
                label: const Text('View All Orders'),
              ),
            ],
          ),
        ),
      );
      }),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                _formatDate(order.placedAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Estimated Delivery: ${_formatDate(order.estimatedDelivery)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    Color bg;
    Color fg;

    switch (status) {
      case OrderStatus.placed:
      case OrderStatus.confirmed:
        bg = Colors.blue.withAlpha(35);
        fg = Colors.blue.shade800;
        break;
      case OrderStatus.shipped:
        bg = Colors.amber.withAlpha(45);
        fg = Colors.orange.shade900;
        break;
      case OrderStatus.outForDelivery:
        bg = Colors.purple.withAlpha(35);
        fg = Colors.purple.shade800;
        break;
      case OrderStatus.delivered:
        bg = Colors.green.withAlpha(35);
        fg = Colors.green.shade800;
        break;
      case OrderStatus.cancelled:
        bg = Colors.red.withAlpha(35);
        fg = Colors.red.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _confirmCancelDialog(
    BuildContext context,
    OrderController controller,
    String orderId,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              controller.cancelOrder(orderId);
              Get.snackbar(
                'Order Cancelled',
                'Your order has been cancelled.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
