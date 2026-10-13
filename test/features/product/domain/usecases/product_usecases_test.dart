import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/product/domain/repositories/product_repository.dart';
import 'package:shop_kart/features/product/domain/usecases/get_categories.dart';
import 'package:shop_kart/features/product/domain/usecases/get_product_detail.dart';
import 'package:shop_kart/features/product/domain/usecases/get_products.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;
  late GetProducts getProductsUseCase;
  late GetCategories getCategoriesUseCase;
  late GetProductDetail getProductDetailUseCase;

  setUp(() {
    mockRepository = MockProductRepository();
    getProductsUseCase = GetProducts(mockRepository);
    getCategoriesUseCase = GetCategories(mockRepository);
    getProductDetailUseCase = GetProductDetail(mockRepository);
  });

  const tProduct = Product(
    id: 1,
    title: 'Test',
    price: 10.0,
    description: 'Desc',
    category: 'Category',
    image: 'img.png',
    rating: 4.5,
    ratingCount: 100,
  );

  test('GetProducts should call repository.getProducts with category', () async {
    when(() => mockRepository.getProducts(category: any(named: 'category')))
        .thenAnswer((_) async => [tProduct]);

    final result = await getProductsUseCase(category: 'electronics');

    expect(result, [tProduct]);
    verify(() => mockRepository.getProducts(category: 'electronics')).called(1);
  });

  test('GetCategories should call repository.getCategories', () async {
    when(() => mockRepository.getCategories())
        .thenAnswer((_) async => ['electronics', 'jewelery']);

    final result = await getCategoriesUseCase();

    expect(result, ['electronics', 'jewelery']);
    verify(() => mockRepository.getCategories()).called(1);
  });

  test('GetProductDetail should call repository.getProduct with id', () async {
    when(() => mockRepository.getProduct(1)).thenAnswer((_) async => tProduct);

    final result = await getProductDetailUseCase(1);

    expect(result, tProduct);
    verify(() => mockRepository.getProduct(1)).called(1);
  });
}
