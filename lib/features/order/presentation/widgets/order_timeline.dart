import 'package:flutter/material.dart';
import 'package:shop_kart/features/order/domain/entities/order_entity.dart';

class OrderTimeline extends StatelessWidget {
  final OrderEntity order;

  const OrderTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCancelled = order.status == OrderStatus.cancelled;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.error.withAlpha(120),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: theme.colorScheme.error, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This order has been cancelled and will not be delivered.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentStep = order.status.stepIndex;

    final steps = [
      _TimelineStepData(
        title: 'Order Placed',
        subtitle: 'We have received your order.',
        icon: Icons.receipt_long_rounded,
        time: _formatDateTime(order.placedAt),
      ),
      _TimelineStepData(
        title: 'Order Confirmed',
        subtitle: 'Seller confirmed & packed your package.',
        icon: Icons.inventory_2_outlined,
        time: currentStep >= 1 ? _formatDateTime(order.placedAt.add(const Duration(minutes: 30))) : null,
      ),
      _TimelineStepData(
        title: 'Shipped',
        subtitle: 'Package dispatched via ShopKart Express.',
        icon: Icons.local_shipping_outlined,
        time: currentStep >= 2 ? _formatDateTime(order.placedAt.add(const Duration(hours: 12))) : null,
      ),
      _TimelineStepData(
        title: 'Out for Delivery',
        subtitle: 'Delivery agent is arriving at your location.',
        icon: Icons.delivery_dining_outlined,
        time: currentStep >= 3 ? _formatDateTime(order.estimatedDelivery) : null,
      ),
      _TimelineStepData(
        title: 'Delivered',
        subtitle: 'Delivered to your doorstep.',
        icon: Icons.home_rounded,
        time: currentStep >= 4 ? _formatDateTime(order.estimatedDelivery) : null,
      ),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isDone = currentStep > index;
        final isCurrent = currentStep == index;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left indicator column
            Column(
              children: [
                _buildCircleIndicator(theme, isDone: isDone, isCurrent: isCurrent, icon: step.icon),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 46,
                    color: isDone
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant.withAlpha(120),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Right description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          step.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent
                                ? theme.colorScheme.primary
                                : (isDone
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                        if (step.time != null)
                          Text(
                            step.time!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCircleIndicator(
    ThemeData theme, {
    required bool isDone,
    required bool isCurrent,
    required IconData icon,
  }) {
    if (isDone) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      );
    }

    if (isCurrent) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.primary, width: 2),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 18),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: theme.colorScheme.outline, size: 16),
    );
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, $hour:$minute $period';
  }
}

class _TimelineStepData {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? time;

  const _TimelineStepData({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.time,
  });
}

