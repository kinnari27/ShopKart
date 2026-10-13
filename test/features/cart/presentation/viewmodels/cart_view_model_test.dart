import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/cart/domain/entities/cart_item.dart';
import 'package:shop_kart/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_kart/features/cart/presentation/viewmodels/cart_view_model.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockRepository;
  late ProviderContainer container;

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

    container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('build should return initial items from repository', () {
    final items = container.read(cartViewModelProvider);
    expect(items, [tCartItem]);
    verify(() => mockRepository.getItems()).called(1);
  });

  test('cartTotalProvider should calculate sum of total for all items', () {
    final total = container.read(cartTotalProvider);
    expect(total, 50.0);
  });

  test('cartItemCountProvider should calculate total quantity of all items', () {
    final count = container.read(cartItemCountProvider);
    expect(count, 2);
  });

  test('add should delegate to repository and update state', () async {
    when(() => mockRepository.add(tProduct)).thenAnswer((_) async {});
    when(() => mockRepository.getItems()).thenReturn([
      tCartItem.copyWith(quantity: 3),
    ]);

    await container.read(cartViewModelProvider.notifier).add(tProduct);

    final items = container.read(cartViewModelProvider);
    expect(items.first.quantity, 3);
    verify(() => mockRepository.add(tProduct)).called(1);
  });

  test('remove should delegate to repository and update state', () async {
    when(() => mockRepository.remove(1)).thenAnswer((_) async {});
    when(() => mockRepository.getItems()).thenReturn([]);

    await container.read(cartViewModelProvider.notifier).remove(1);

    final items = container.read(cartViewModelProvider);
    expect(items, isEmpty);
    verify(() => mockRepository.remove(1)).called(1);
  });

  test('updateQuantity should delegate to repository and update state', () async {
    when(() => mockRepository.updateQuantity(1, 4)).thenAnswer((_) async {});
    when(() => mockRepository.getItems()).thenReturn([
      tCartItem.copyWith(quantity: 4),
    ]);

    await container.read(cartViewModelProvider.notifier).updateQuantity(1, 4);

    final items = container.read(cartViewModelProvider);
    expect(items.first.quantity, 4);
    verify(() => mockRepository.updateQuantity(1, 4)).called(1);
  });

  test('clear should delegate to repository and update state to empty', () async {
    when(() => mockRepository.clear()).thenAnswer((_) async {});
    when(() => mockRepository.getItems()).thenReturn([]);

    await container.read(cartViewModelProvider.notifier).clear();

    final items = container.read(cartViewModelProvider);
    expect(items, isEmpty);
    verify(() => mockRepository.clear()).called(1);
  });
}
