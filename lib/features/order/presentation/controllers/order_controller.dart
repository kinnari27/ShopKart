import 'package:get/get.dart';
import 'package:shop_kart/features/cart/domain/entities/cart_item.dart';
import 'package:shop_kart/features/order/domain/entities/order_entity.dart';
import 'package:shop_kart/features/order/domain/repositories/order_repository.dart';
import 'package:shop_kart/injection/injection.dart';

class OrderController extends GetxController {
  static OrderController get to => Get.find();

  final OrderRepository _repository;

  OrderController({OrderRepository? repository})
      : _repository = repository ?? sl<OrderRepository>() {
    loadOrders();
  }

  final RxList<OrderEntity> orders = <OrderEntity>[].obs;
  final Rx<OrderEntity?> currentOrder = Rx<OrderEntity?>(null);
  final RxBool isLoading = false.obs;

  void loadOrders() {
    orders.assignAll(_repository.getOrders());
  }

  void selectOrder(String orderId) {
    currentOrder.value = _repository.getOrderById(orderId);
  }

  Future<OrderEntity> placeOrder({
    required List<CartItem> items,
    required double total,
    String? deliveryAddress,
    String? paymentMethod,
  }) async {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      final randomSuffix = (now.millisecondsSinceEpoch % 900000 + 100000).toString();
      final orderId = 'SK-$randomSuffix';

      final orderItems = items
          .map(
            (item) => OrderItemEntity(
              productId: item.product.id,
              title: item.product.title,
              price: item.product.price,
              image: item.product.image,
              quantity: item.quantity,
              size: item.size,
            ),
          )
          .toList();

      final order = OrderEntity(
        id: orderId,
        items: orderItems,
        totalAmount: total,
        placedAt: now,
        status: OrderStatus.confirmed,
        deliveryAddress: deliveryAddress ??
            'Flat 402, Sunset Heights, Silicon Valley, CA 94016',
        estimatedDelivery: now.add(const Duration(days: 4)),
        paymentMethod: paymentMethod ?? 'Cash on Delivery',
      );

      await _repository.saveOrder(order);
      loadOrders();
      currentOrder.value = order;
      return order;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> advanceStatus(String orderId) async {
    final order = _repository.getOrderById(orderId);
    if (order == null || order.status == OrderStatus.cancelled) return;

    OrderStatus? nextStatus;
    switch (order.status) {
      case OrderStatus.placed:
        nextStatus = OrderStatus.confirmed;
        break;
      case OrderStatus.confirmed:
        nextStatus = OrderStatus.shipped;
        break;
      case OrderStatus.shipped:
        nextStatus = OrderStatus.outForDelivery;
        break;
      case OrderStatus.outForDelivery:
        nextStatus = OrderStatus.delivered;
        break;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        break;
    }

    if (nextStatus != null) {
      await _repository.updateOrderStatus(orderId, nextStatus);
      loadOrders();
      currentOrder.value = _repository.getOrderById(orderId);
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await _repository.cancelOrder(orderId);
    loadOrders();
    currentOrder.value = _repository.getOrderById(orderId);
  }
}

