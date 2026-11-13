import 'package:equatable/equatable.dart';

enum OrderStatus {
  placed,
  confirmed,
  shipped,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}

class OrderItemEntity extends Equatable {
  const OrderItemEntity({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
    this.size,
  });

  final int productId;
  final String title;
  final double price;
  final String image;
  final int quantity;
  final String? size;

  double get total => price * quantity;

  @override
  List<Object?> get props => [productId, title, price, image, quantity, size];
}

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.placedAt,
    required this.status,
    required this.deliveryAddress,
    required this.estimatedDelivery,
    this.paymentMethod = 'Cash on Delivery',
  });

  final String id;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final DateTime placedAt;
  final OrderStatus status;
  final String deliveryAddress;
  final DateTime estimatedDelivery;
  final String paymentMethod;

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  OrderEntity copyWith({
    String? id,
    List<OrderItemEntity>? items,
    double? totalAmount,
    DateTime? placedAt,
    OrderStatus? status,
    String? deliveryAddress,
    DateTime? estimatedDelivery,
    String? paymentMethod,
  }) => OrderEntity(
    id: id ?? this.id,
    items: items ?? this.items,
    totalAmount: totalAmount ?? this.totalAmount,
    placedAt: placedAt ?? this.placedAt,
    status: status ?? this.status,
    deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    paymentMethod: paymentMethod ?? this.paymentMethod,
  );

  @override
  List<Object?> get props => [
    id,
    items,
    totalAmount,
    placedAt,
    status,
    deliveryAddress,
    estimatedDelivery,
    paymentMethod,
  ];
}

