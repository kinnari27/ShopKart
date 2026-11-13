import 'package:shop_kart/features/order/domain/entities/order_entity.dart';

abstract class OrderRepository {
  List<OrderEntity> getOrders();
  OrderEntity? getOrderById(String id);
  Future<void> saveOrder(OrderEntity order);
  Future<void> updateOrderStatus(String id, OrderStatus status);
  Future<void> cancelOrder(String id);
}

