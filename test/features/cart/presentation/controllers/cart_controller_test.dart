import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/cart/domain/entities/cart_item.dart';
import 'package:shop_kart/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_kart/features/cart/presentation/controllers/cart_controller.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockRepository;
  late CartController controller;

  const tProduct = Product(
    id: 1,
    title: 'Item 1',
    price: 25.0,
    description: 'Desc',
    category: 'Category',
    image: 'img.png',
    rating: 4.0,
    ratingCount: 10,
  );

  const tCartItem = CartItem(product: tProduct, quantity: 2);

  setUp(() {
    mockRepository = MockCartRepository();
    when(() => mockRepository.getItems()).thenReturn([tCartItem]);
    controller = CartController(repository: mockRepository);
  });

  test('onInit should return initial items from repository', () {
    expect(controller.items, [tCartItem]);
    verify(() => mockRepository.getItems()).called(1);
  });

  test('total should calculate sum of total for all items', () {
    expect(controller.total, 50.0);
  });

  test('itemCount should calculate total quantity of all items', () {
    expect(controller.itemCount, 2);
  });

  test('add should delegate to repository and update state', () async {
    when(() => mockRepository.add(tProduct, size: any(named: 'size')))
        .thenAnswer((_) async {});
    when(() => mockRepository.getItems()).thenReturn([
      tCartItem.copyWith(quantity: 3),
    ]);

    await controller.add(tProduct);

    expect(controller.items.first.quantity, 3);
    verify(() => mockRepository.add(tProduct, size: any(named: 'size'))).called(1);
  });

  test('add with size should delegate to repository with size', () async {
    when(() => mockRepository.add(tProduct, size: 'L')).thenAnswer((_) async {});
    when(() => mockRepository.getItems()).thenReturn([
      tCartItem.copyWith(size: 'L'),
    ]);

    await controller.add(tProduct, size: 'L');

    expect(controller.items.first.size, 'L');
    verify(() => mockRepository.add(tProduct, size: 'L')).called(1);
  });

  test('remove should delegate to repository and update state', () async {
    when(() => mockRepository.remove(1)).thenAnswer((_) async {});
    when(() => mockRepository.getItems()).thenReturn([]);

    await controller.remove(1);

    expect(controller.items, isEmpty);
    verify(() => mockRepository.remove(1)).called(1);
  });

  test('updateQuantity should delegate to repository and update state', () async {
    when(() => mockRepository.updateQuantity(1, 4)).thenAnswer((_) async {});
    when(() => mockRepository.getItems()).thenReturn([
      tCartItem.copyWith(quantity: 4),
    ]);

    await controller.updateQuantity(1, 4);

    expect(controller.items.first.quantity, 4);
    verify(() => mockRepository.updateQuantity(1, 4)).called(1);
  });

  test('clear should delegate to repository and update state to empty', () async {
    when(() => mockRepository.clear()).thenAnswer((_) async {});
    when(() => mockRepository.getItems()).thenReturn([]);

    await controller.clear();

    expect(controller.items, isEmpty);
    verify(() => mockRepository.clear()).called(1);
  });
}
