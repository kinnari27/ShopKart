import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class MockCartBox extends Mock implements Box<Map> {}

void main() {
  late MockCartBox mockBox;
  late CartRepositoryImpl repository;

  setUp(() {
    mockBox = MockCartBox();
    repository = CartRepositoryImpl(mockBox);
  });

  const tProduct = Product(
    id: 1,
    title: 'Cart Item',
    price: 49.99,
    description: 'Desc',
    category: 'clothing',
    image: 'item.png',
    rating: 4.5,
    ratingCount: 80,
  );

  test('getItems should return mapped CartItem list from box values', () {
    when(() => mockBox.values).thenReturn([
      {
        'product': {
          'id': 1,
          'title': 'Cart Item',
          'price': 49.99,
          'description': 'Desc',
          'category': 'clothing',
          'image': 'item.png',
          'rating': {'rate': 4.5, 'count': 80},
        },
        'quantity': 2,
      }
    ]);

    final items = repository.getItems();

    expect(items.length, 1);
    expect(items.first.product.id, 1);
    expect(items.first.quantity, 2);
    expect(items.first.total, 49.99 * 2);
  });

  test('add should increment quantity when product already exists in cart', () async {
    when(() => mockBox.get(1)).thenReturn({
      'product': {},
      'quantity': 2,
    });
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

    await repository.add(tProduct);

    verify(() => mockBox.put(1, any(that: isA<Map>().having(
      (m) => m['quantity'],
      'quantity',
      3,
    )))).called(1);
  });

  test('add should set quantity to 1 when product is not in cart', () async {
    when(() => mockBox.get(1)).thenReturn(null);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

    await repository.add(tProduct);

    verify(() => mockBox.put(1, any(that: isA<Map>().having(
      (m) => m['quantity'],
      'quantity',
      1,
    )))).called(1);
  });

  test('updateQuantity should update quantity when > 0', () async {
    when(() => mockBox.get(1)).thenReturn({'quantity': 1, 'product': {}});
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

    await repository.updateQuantity(1, 5);

    verify(() => mockBox.put(1, any(that: isA<Map>().having(
      (m) => m['quantity'],
      'quantity',
      5,
    )))).called(1);
  });

  test('updateQuantity should delete item when quantity is 0 or less', () async {
    when(() => mockBox.delete(1)).thenAnswer((_) async {});

    await repository.updateQuantity(1, 0);

    verify(() => mockBox.delete(1)).called(1);
  });

  test('remove should delete item by id', () async {
    when(() => mockBox.delete(1)).thenAnswer((_) async {});

    await repository.remove(1);

    verify(() => mockBox.delete(1)).called(1);
  });

  test('clear should empty the box', () async {
    when(() => mockBox.clear()).thenAnswer((_) async => 0);

    await repository.clear();

    verify(() => mockBox.clear()).called(1);
  });
}
