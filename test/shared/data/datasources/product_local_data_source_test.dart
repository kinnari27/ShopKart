import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/core/errors/app_exception.dart';
import 'package:shop_kart/shared/data/datasources/product_local_data_source.dart';
import 'package:shop_kart/shared/data/models/product_model.dart';

class MockMapBox extends Mock implements Box<Map> {}
class MockListBox extends Mock implements Box<List> {}

void main() {
  late MockMapBox mockProductBox;
  late MockListBox mockListBox;
  late ProductLocalDataSource dataSource;

  setUp(() {
    mockProductBox = MockMapBox();
    mockListBox = MockListBox();
    dataSource = ProductLocalDataSource(
      productBox: mockProductBox,
      listBox: mockListBox,
    );
  });

  const tProductModel1 = ProductModel(
    id: 1,
    title: 'Product 1',
    price: 20.0,
    description: 'Desc 1',
    category: 'electronics',
    image: 'img1.png',
    rating: 4.0,
    ratingCount: 10,
  );

  const tProductModel2 = ProductModel(
    id: 2,
    title: 'Product 2',
    price: 30.0,
    description: 'Desc 2',
    category: 'jewelery',
    image: 'img2.png',
    rating: 4.8,
    ratingCount: 25,
  );

  group('cacheProducts and getCachedProducts', () {
    test('cacheProducts should merge IDs into existing IDs and put in productBox', () async {
      when(() => mockListBox.get('ids', defaultValue: any(named: 'defaultValue')))
          .thenReturn([1]);
      when(() => mockListBox.put(any(), any())).thenAnswer((_) async {});
      when(() => mockProductBox.put(any(), any())).thenAnswer((_) async {});

      await dataSource.cacheProducts([tProductModel2]);

      verify(() => mockListBox.put('ids', [1, 2])).called(1);
      verify(() => mockProductBox.put(2, tProductModel2.toJson())).called(1);
    });

    test('getCachedProducts should return products when available', () {
      when(() => mockListBox.get('ids', defaultValue: any(named: 'defaultValue')))
          .thenReturn([1, 2]);
      when(() => mockProductBox.get(1)).thenReturn(tProductModel1.toJson());
      when(() => mockProductBox.get(2)).thenReturn(tProductModel2.toJson());

      final result = dataSource.getCachedProducts();

      expect(result.length, 2);
      expect(result.first.id, 1);
      expect(result.last.id, 2);
    });

    test('getCachedProducts should filter by category when category is specified', () {
      when(() => mockListBox.get('ids', defaultValue: any(named: 'defaultValue')))
          .thenReturn([1, 2]);
      when(() => mockProductBox.get(1)).thenReturn(tProductModel1.toJson());
      when(() => mockProductBox.get(2)).thenReturn(tProductModel2.toJson());

      final result = dataSource.getCachedProducts(category: 'jewelery');

      expect(result.length, 1);
      expect(result.first.category, 'jewelery');
      expect(result.first.id, 2);
    });

    test('getCachedProducts should throw CacheException when empty', () {
      when(() => mockListBox.get('ids', defaultValue: any(named: 'defaultValue')))
          .thenReturn([]);

      expect(() => dataSource.getCachedProducts(), throwsA(isA<CacheException>()));
    });
  });

  group('categories cache', () {
    test('cacheCategories should put list of categories into listBox', () async {
      when(() => mockListBox.put('categories', any())).thenAnswer((_) async {});

      await dataSource.cacheCategories(['electronics', 'jewelery']);

      verify(() => mockListBox.put('categories', ['electronics', 'jewelery'])).called(1);
    });

    test('getCachedCategories should return string list from listBox', () {
      when(() => mockListBox.get('categories', defaultValue: any(named: 'defaultValue')))
          .thenReturn(['electronics', 'jewelery']);

      final result = dataSource.getCachedCategories();

      expect(result, ['electronics', 'jewelery']);
    });
  });
}
