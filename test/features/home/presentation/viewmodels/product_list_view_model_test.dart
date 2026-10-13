import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/home/presentation/viewmodels/product_list_view_model.dart';
import 'package:shop_kart/features/product/domain/usecases/get_categories.dart';
import 'package:shop_kart/features/product/domain/usecases/get_products.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class MockGetProducts extends Mock implements GetProducts {}
class MockGetCategories extends Mock implements GetCategories {}

void main() {
  late MockGetProducts mockGetProducts;
  late MockGetCategories mockGetCategories;
  late ProviderContainer container;

  final tProducts = List.generate(
    15,
    (index) => Product(
      id: index + 1,
      title: 'Product ${index + 1}',
      price: 10.0 + index,
      description: 'Description for ${index + 1}',
      category: index.isEven ? 'electronics' : 'jewelery',
      image: 'img$index.png',
      rating: 4.0,
      ratingCount: 10 + index,
    ),
  );

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockGetCategories = MockGetCategories();

    when(() => mockGetCategories.call()).thenAnswer((_) async => ['All', 'electronics', 'jewelery']);
    when(() => mockGetProducts.call(category: any(named: 'category')))
        .thenAnswer((_) async => tProducts);

    container = ProviderContainer(
      overrides: [
        getProductsUseCaseProvider.overrideWithValue(mockGetProducts),
        getCategoriesUseCaseProvider.overrideWithValue(mockGetCategories),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('build should load products and categories into initial state', () async {
    final state = await container.read(productListViewModelProvider.future);

    expect(state.products.length, 15);
    expect(state.visibleProducts.length, 10); // Page size is 10
    expect(state.categories, ['All', 'electronics', 'jewelery']);
    expect(state.hasMore, isTrue);
  });

  test('search should filter visibleProducts according to query', () async {
    await container.read(productListViewModelProvider.future);

    container.read(productListViewModelProvider.notifier).search('Product 1');
    final state = container.read(productListViewModelProvider).value!;

    expect(state.query, 'Product 1');
    expect(state.visibleProducts.every((p) => p.title.contains('Product 1')), isTrue);
  });

  test('loadNextPage should append more visibleProducts', () async {
    await container.read(productListViewModelProvider.future);

    container.read(productListViewModelProvider.notifier).loadNextPage();
    final state = container.read(productListViewModelProvider).value!;

    expect(state.page, 2);
    expect(state.visibleProducts.length, 15);
    expect(state.hasMore, isFalse);
  });

  test('selectCategory should fetch products for category', () async {
    await container.read(productListViewModelProvider.future);

    final electronicsOnly = tProducts.where((p) => p.category == 'electronics').toList();
    when(() => mockGetProducts.call(category: 'electronics'))
        .thenAnswer((_) async => electronicsOnly);

    await container.read(productListViewModelProvider.notifier).selectCategory('electronics');
    final state = container.read(productListViewModelProvider).value!;

    expect(state.selectedCategory, 'electronics');
    expect(state.products.length, electronicsOnly.length);
  });
}
