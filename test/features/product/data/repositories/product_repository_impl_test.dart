import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/core/errors/app_exception.dart';
import 'package:shop_kart/features/product/data/repositories/product_repository_impl.dart';
import 'package:shop_kart/shared/data/datasources/product_local_data_source.dart';
import 'package:shop_kart/shared/data/datasources/product_remote_data_source.dart';
import 'package:shop_kart/shared/data/models/product_model.dart';

class MockProductRemoteDataSource extends Mock implements ProductRemoteDataSource {}
class MockProductLocalDataSource extends Mock implements ProductLocalDataSource {}

void main() {
  late MockProductRemoteDataSource mockRemote;
  late MockProductLocalDataSource mockLocal;
  late ProductRepositoryImpl repository;

  setUp(() {
    mockRemote = MockProductRemoteDataSource();
    mockLocal = MockProductLocalDataSource();
    repository = ProductRepositoryImpl(mockRemote, mockLocal);
  });

  const tProductModel = ProductModel(
    id: 1,
    title: 'Test',
    price: 15.0,
    description: 'Desc',
    category: 'electronics',
    image: 'image.png',
    rating: 4.2,
    ratingCount: 50,
  );

  group('getProducts', () {
    test('should fetch products from remote and cache them on success', () async {
      when(() => mockRemote.getProducts()).thenAnswer((_) async => [tProductModel]);
      when(() => mockLocal.cacheProducts(any())).thenAnswer((_) async {});

      final result = await repository.getProducts();

      expect(result, [tProductModel]);
      verify(() => mockRemote.getProducts()).called(1);
      verify(() => mockLocal.cacheProducts([tProductModel])).called(1);
    });

    test('should fetch by category when specified', () async {
      when(() => mockRemote.getProductsByCategory('electronics'))
          .thenAnswer((_) async => [tProductModel]);
      when(() => mockLocal.cacheProducts(any())).thenAnswer((_) async {});

      final result = await repository.getProducts(category: 'electronics');

      expect(result, [tProductModel]);
      verify(() => mockRemote.getProductsByCategory('electronics')).called(1);
      verify(() => mockLocal.cacheProducts([tProductModel])).called(1);
    });

    test('should return cached products on DioException', () async {
      when(() => mockRemote.getProducts()).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/products')),
      );
      when(() => mockLocal.getCachedProducts(category: any(named: 'category')))
          .thenReturn([tProductModel]);

      final result = await repository.getProducts();

      expect(result, [tProductModel]);
      verify(() => mockLocal.getCachedProducts(category: null)).called(1);
    });

    test('should rethrow CacheException when cache is also empty on DioException', () async {
      when(() => mockRemote.getProducts()).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/products')),
      );
      when(() => mockLocal.getCachedProducts(category: any(named: 'category')))
          .thenThrow(const CacheException('No cached products available.'));

      expect(() => repository.getProducts(), throwsA(isA<CacheException>()));
    });
  });

  group('getProduct', () {
    test('should fetch product from remote and cache it', () async {
      when(() => mockRemote.getProduct(1)).thenAnswer((_) async => tProductModel);
      when(() => mockLocal.cacheProducts(any())).thenAnswer((_) async {});

      final result = await repository.getProduct(1);

      expect(result, tProductModel);
      verify(() => mockRemote.getProduct(1)).called(1);
      verify(() => mockLocal.cacheProducts([tProductModel])).called(1);
    });

    test('should return cached product when remote fails', () async {
      when(() => mockRemote.getProduct(1)).thenThrow(Exception('Network error'));
      when(() => mockLocal.getCachedProducts()).thenReturn([tProductModel]);

      final result = await repository.getProduct(1);

      expect(result, tProductModel);
    });
  });

  group('getCategories', () {
    test('should return categories with All prepended on remote success', () async {
      when(() => mockRemote.getCategories()).thenAnswer((_) async => ['electronics']);
      when(() => mockLocal.cacheCategories(any())).thenAnswer((_) async {});

      final result = await repository.getCategories();

      expect(result, ['All', 'electronics']);
      verify(() => mockLocal.cacheCategories(['electronics'])).called(1);
    });

    test('should fallback to cached categories on error', () async {
      when(() => mockRemote.getCategories()).thenThrow(Exception('Error'));
      when(() => mockLocal.getCachedCategories()).thenReturn(['jewelery']);

      final result = await repository.getCategories();

      expect(result, ['All', 'jewelery']);
    });
  });
}
