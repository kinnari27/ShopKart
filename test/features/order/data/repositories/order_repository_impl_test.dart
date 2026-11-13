import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/order/data/repositories/order_repository_impl.dart';
import 'package:shop_kart/features/order/domain/entities/order_entity.dart';

class MockOrderBox extends Mock implements Box<Map> {}

void main() {
  late MockOrderBox mockBox;
  late OrderRepositoryImpl repository;

  setUp(() {
    mockBox = MockOrderBox();
    repository = OrderRepositoryImpl(mockBox);
  });

  final tOrder = OrderEntity(
    id: 'SK-123456',
    items: const [
      OrderItemEntity(
        productId: 1,
        title: 'Test Shirt',
        price: 29.99,
        image: 'shirt.png',
        quantity: 2,
        size: 'L',
      ),
    ],
    totalAmount: 59.98,
    placedAt: DateTime(2026, 11, 13, 10, 0),
    status: OrderStatus.confirmed,
    deliveryAddress: '123 Main St',
    estimatedDelivery: DateTime(2026, 11, 17),
    paymentMethod: 'Cash on Delivery',
  );

  test('getOrders should return sorted order list from box values', () {
    when(() => mockBox.values).thenReturn([
      {
        'id': 'SK-1',
        'items': [
          {
            'productId': 1,
            'title': 'Test Item',
            'price': 10.0,
            'image': 'item.png',
            'quantity': 1,
          }
        ],
        'totalAmount': 10.0,
        'placedAt': '2026-11-13T09:00:00.000',
        'status': 'placed',
        'deliveryAddress': 'Address',
        'estimatedDelivery': '2026-11-17T09:00:00.000',
        'paymentMethod': 'Cash on Delivery',
      },
      {
        'id': 'SK-2',
        'items': [
          {
            'productId': 2,
            'title': 'Newer Item',
            'price': 20.0,
            'image': 'item2.png',
            'quantity': 1,
          }
        ],
        'totalAmount': 20.0,
        'placedAt': '2026-11-13T10:00:00.000',
        'status': 'confirmed',
        'deliveryAddress': 'Address',
        'estimatedDelivery': '2026-11-17T10:00:00.000',
        'paymentMethod': 'Cash on Delivery',
      },
    ]);

    final orders = repository.getOrders();

    expect(orders.length, 2);
    expect(orders.first.id, 'SK-2'); // Sorted descending by placedAt
    expect(orders.last.id, 'SK-1');
  });

  test('getOrderById should return parsed order when found', () {
    when(() => mockBox.get('SK-123456')).thenReturn({
      'id': 'SK-123456',
      'items': [
        {
          'productId': 1,
          'title': 'Test Shirt',
          'price': 29.99,
          'image': 'shirt.png',
          'quantity': 2,
          'size': 'L',
        }
      ],
      'totalAmount': 59.98,
      'placedAt': '2026-11-13T10:00:00.000',
      'status': 'confirmed',
      'deliveryAddress': '123 Main St',
      'estimatedDelivery': '2026-11-17T00:00:00.000',
      'paymentMethod': 'Cash on Delivery',
    });

    final result = repository.getOrderById('SK-123456');

    expect(result, isNotNull);
    expect(result!.id, 'SK-123456');
    expect(result.items.first.size, 'L');
    expect(result.status, OrderStatus.confirmed);
  });

  test('saveOrder should put order map into box', () async {
    when(() => mockBox.put('SK-123456', any())).thenAnswer((_) async {});

    await repository.saveOrder(tOrder);

    verify(() => mockBox.put('SK-123456', any())).called(1);
  });

  test('updateOrderStatus should update order status and save to box', () async {
    when(() => mockBox.get('SK-123456')).thenReturn({
      'id': 'SK-123456',
      'items': [],
      'totalAmount': 59.98,
      'placedAt': '2026-11-13T10:00:00.000',
      'status': 'confirmed',
      'deliveryAddress': '123 Main St',
      'estimatedDelivery': '2026-11-17T00:00:00.000',
      'paymentMethod': 'Cash on Delivery',
    });
    when(() => mockBox.put('SK-123456', any())).thenAnswer((_) async {});

    await repository.updateOrderStatus('SK-123456', OrderStatus.shipped);

    verify(() => mockBox.put('SK-123456', any())).called(1);
  });

  test('cancelOrder should set status to cancelled', () async {
    when(() => mockBox.get('SK-123456')).thenReturn({
      'id': 'SK-123456',
      'items': [],
      'totalAmount': 59.98,
      'placedAt': '2026-11-13T10:00:00.000',
      'status': 'confirmed',
      'deliveryAddress': '123 Main St',
      'estimatedDelivery': '2026-11-17T00:00:00.000',
      'paymentMethod': 'Cash on Delivery',
    });
    when(() => mockBox.put('SK-123456', any())).thenAnswer((_) async {});

    await repository.cancelOrder('SK-123456');

    verify(() => mockBox.put('SK-123456', any())).called(1);
  });
}

