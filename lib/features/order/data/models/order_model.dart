import 'package:shop_kart/features/order/domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.title,
    required super.price,
    required super.image,
    required super.quantity,
    super.size,
  });

  factory OrderItemModel.fromJson(Map<dynamic, dynamic> json) {
    return OrderItemModel(
      productId: (json['productId'] as num).toInt(),
      title: json['title'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String? ?? '',
      quantity: (json['quantity'] as num).toInt(),
      size: json['size'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'title': title,
    'price': price,
    'image': image,
    'quantity': quantity,
    if (size != null) 'size': size,
  };
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.items,
    required super.totalAmount,
    required super.placedAt,
    required super.status,
    required super.deliveryAddress,
    required super.estimatedDelivery,
    super.paymentMethod,
  });

  factory OrderModel.fromJson(Map<dynamic, dynamic> json) {
    final rawItems = json['items'];
    final items = <OrderItemEntity>[];
    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is Map) {
          items.add(OrderItemModel.fromJson(raw));
        }
      }
    }

    final statusString = json['status'] as String? ?? 'placed';
    final status = OrderStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => OrderStatus.placed,
    );

    return OrderModel(
      id: json['id'] as String? ?? '',
      items: items,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      placedAt: json['placedAt'] != null
          ? DateTime.parse(json['placedAt'] as String)
          : DateTime.now(),
      status: status,
      deliveryAddress:
          json['deliveryAddress'] as String? ?? 'Home Address, Main City',
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'] as String)
          : DateTime.now().add(const Duration(days: 4)),
      paymentMethod:
          json['paymentMethod'] as String? ?? 'Cash on Delivery',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items
        .map((e) => (e is OrderItemModel ? e : OrderItemModel(
              productId: e.productId,
              title: e.title,
              price: e.price,
              image: e.image,
              quantity: e.quantity,
              size: e.size,
            )).toJson())
        .toList(),
    'totalAmount': totalAmount,
    'placedAt': placedAt.toIso8601String(),
    'status': status.name,
    'deliveryAddress': deliveryAddress,
    'estimatedDelivery': estimatedDelivery.toIso8601String(),
    'paymentMethod': paymentMethod,
  };
}

