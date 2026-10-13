import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class MockWishlistBox extends Mock implements Box<Map> {}

void main() {
  late MockWishlistBox mockBox;
  late WishlistRepositoryImpl repository;

  setUp(() {
    mockBox = MockWishlistBox();
    repository = WishlistRepositoryImpl(mockBox);
  });

  const tProduct = Product(
    id: 1,
    title: 'Wishlist Item',
    price: 35.0,
    description: 'Desc',
    category: 'fashion',
    image: 'item.png',
    rating: 4.6,
    ratingCount: 15,
  );

  test('getItems should return products from box values', () {
    when(() => mockBox.values).thenReturn([
      {
        'id': 1,
        'title': 'Wishlist Item',
        'price': 35.0,
        'description': 'Desc',
        'category': 'fashion',
        'image': 'item.png',
        'rating': {'rate': 4.6, 'count': 15},
      }
    ]);

    final items = repository.getItems();

    expect(items.length, 1);
    expect(items.first.id, 1);
    expect(items.first.title, 'Wishlist Item');
  });

  test('contains should check box containsKey', () {
    when(() => mockBox.containsKey(1)).thenReturn(true);
    when(() => mockBox.containsKey(2)).thenReturn(false);

    expect(repository.contains(1), isTrue);
    expect(repository.contains(2), isFalse);
  });

  test('toggle should delete item if already in box', () async {
    when(() => mockBox.containsKey(1)).thenReturn(true);
    when(() => mockBox.delete(1)).thenAnswer((_) async {});

    await repository.toggle(tProduct);

    verify(() => mockBox.delete(1)).called(1);
  });

  test('toggle should put item if not in box', () async {
    when(() => mockBox.containsKey(1)).thenReturn(false);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

    await repository.toggle(tProduct);

    verify(() => mockBox.put(1, any())).called(1);
  });
}
