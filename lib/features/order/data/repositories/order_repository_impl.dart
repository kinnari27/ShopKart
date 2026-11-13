import 'package:hive/hive.dart';
import 'package:shop_kart/features/order/data/models/order_model.dart';
import 'package:shop_kart/features/order/domain/entities/order_entity.dart';
import 'package:shop_kart/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final Box<Map> _box;

  OrderRepositoryImpl(this._box);

  @override
  List<OrderEntity> getOrders() {
    final list = _box.values
        .whereType<Map>()
        .map((json) => OrderModel.fromJson(json))
        .toList();
    list.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return list;
  }

  @override
  OrderEntity? getOrderById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return OrderModel.fromJson(raw);
  }

  @override
  Future<void> saveOrder(OrderEntity order) async {
    final model = order is OrderModel
        ? order
        : OrderModel(
            id: order.id,
            items: order.items,
            totalAmount: order.totalAmount,
            placedAt: order.placedAt,
            status: order.status,
            deliveryAddress: order.deliveryAddress,
            estimatedDelivery: order.estimatedDelivery,
            paymentMethod: order.paymentMethod,
          );
    await _box.put(order.id, model.toJson());
  }

  @override
  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    final order = getOrderById(id);
    if (order != null) {
      final updated = order.copyWith(status: status);
      await saveOrder(updated);
    }
  }

  @override
  Future<void> cancelOrder(String id) async {
    await updateOrderStatus(id, OrderStatus.cancelled);
  }
}

