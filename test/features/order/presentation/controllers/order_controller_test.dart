import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/cart/domain/entities/cart_item.dart';
import 'package:shop_kart/features/order/domain/entities/order_entity.dart';
import 'package:shop_kart/features/order/domain/repositories/order_repository.dart';
import 'package:shop_kart/features/order/presentation/controllers/order_controller.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class FakeOrderEntity extends Fake implements OrderEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOrderEntity());
  });

  late MockOrderRepository mockRepository;
  late OrderController controller;

  const tProduct = Product(
    id: 1,
    title: 'Test Shirt',
    price: 30.0,
    description: 'Desc',
    category: 'clothing',
    image: 'shirt.png',
    rating: 4.2,
    ratingCount: 50,
  );

  const tCartItem = CartItem(product: tProduct, quantity: 2, size: 'M');

  final tOrder = OrderEntity(
    id: 'SK-999',
    items: const [
      OrderItemEntity(
        productId: 1,
        title: 'Test Shirt',
        price: 30.0,
        image: 'shirt.png',
        quantity: 2,
        size: 'M',
      ),
    ],
    totalAmount: 60.0,
    placedAt: DateTime(2026, 11, 13),
    status: OrderStatus.confirmed,
    deliveryAddress: '123 Main St',
    estimatedDelivery: DateTime(2026, 11, 17),
    paymentMethod: 'Cash on Delivery',
  );

  setUp(() {
    mockRepository = MockOrderRepository();
    when(() => mockRepository.getOrders()).thenReturn([tOrder]);
    controller = OrderController(repository: mockRepository);
  });

  test('onInit should load orders from repository', () {
    expect(controller.orders.length, 1);
    expect(controller.orders.first.id, 'SK-999');
    verify(() => mockRepository.getOrders()).called(1);
  });

  test('selectOrder should update currentOrder', () {
    when(() => mockRepository.getOrderById('SK-999')).thenReturn(tOrder);

    controller.selectOrder('SK-999');

    expect(controller.currentOrder.value, tOrder);
    verify(() => mockRepository.getOrderById('SK-999')).called(1);
  });

  test('placeOrder should save order and update orders list', () async {
    when(() => mockRepository.saveOrder(any())).thenAnswer((_) async {});
    when(() => mockRepository.getOrders()).thenReturn([tOrder]);

    final placed = await controller.placeOrder(
      items: [tCartItem],
      total: 60.0,
      deliveryAddress: '123 Main St',
      paymentMethod: 'Cash on Delivery',
    );

    expect(placed.totalAmount, 60.0);
    expect(placed.items.first.title, 'Test Shirt');
    expect(placed.items.first.size, 'M');
    expect(placed.status, OrderStatus.confirmed);
    verify(() => mockRepository.saveOrder(any())).called(1);
  });

  test('advanceStatus should progress to next status', () async {
    when(() => mockRepository.getOrderById('SK-999')).thenReturn(tOrder);
    when(() => mockRepository.updateOrderStatus('SK-999', OrderStatus.shipped))
        .thenAnswer((_) async {});
    final shippedOrder = tOrder.copyWith(status: OrderStatus.shipped);
    when(() => mockRepository.getOrders()).thenReturn([shippedOrder]);

    await controller.advanceStatus('SK-999');

    verify(() => mockRepository.updateOrderStatus('SK-999', OrderStatus.shipped)).called(1);
  });

  test('cancelOrder should delegate to repository and update state', () async {
    when(() => mockRepository.cancelOrder('SK-999')).thenAnswer((_) async {});
    final cancelledOrder = tOrder.copyWith(status: OrderStatus.cancelled);
    when(() => mockRepository.getOrderById('SK-999')).thenReturn(cancelledOrder);
    when(() => mockRepository.getOrders()).thenReturn([cancelledOrder]);

    await controller.cancelOrder('SK-999');

    verify(() => mockRepository.cancelOrder('SK-999')).called(1);
  });
}

