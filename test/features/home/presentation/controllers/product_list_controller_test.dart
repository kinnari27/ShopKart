import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/home/presentation/controllers/product_list_controller.dart';
import 'package:shop_kart/features/product/domain/usecases/get_categories.dart';
import 'package:shop_kart/features/product/domain/usecases/get_products.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class MockGetProducts extends Mock implements GetProducts {}

class MockGetCategories extends Mock implements GetCategories {}

void main() {
  late MockGetProducts mockGetProducts;
  late MockGetCategories mockGetCategories;
  late ProductListController controller;

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

    when(() => mockGetCategories.call())
        .thenAnswer((_) async => ['All', 'electronics', 'jewelery']);
    when(() => mockGetProducts.call(category: any(named: 'category')))
        .thenAnswer((_) async => tProducts);

    controller = ProductListController(
      getProducts: mockGetProducts,
      getCategories: mockGetCategories,
    );
  });

  test('loadInitialData should load products and categories into initial state', () async {
    final state = await controller.loadInitialData();

    expect(state.products.length, 15);
    expect(state.visibleProducts.length, 10); // Page size is 10
    expect(state.categories, ['All', 'electronics', 'jewelery']);
    expect(state.hasMore, isTrue);
  });

  test('search should filter visibleProducts according to query', () async {
    await controller.loadInitialData();

    controller.search('Product 1');
    final state = controller.state;

    expect(state.query, 'Product 1');
    expect(
      state.visibleProducts.every((p) => p.title.contains('Product 1')),
      isTrue,
    );
  });

  test('loadNextPage should append more visibleProducts', () async {
    await controller.loadInitialData();

    controller.loadNextPage();
    final state = controller.state;

    expect(state.page, 2);
    expect(state.visibleProducts.length, 15);
    expect(state.hasMore, isFalse);
  });

  test('selectCategory should fetch products for category', () async {
    await controller.loadInitialData();

    final electronicsOnly =
        tProducts.where((p) => p.category == 'electronics').toList();
    when(() => mockGetProducts.call(category: 'electronics'))
        .thenAnswer((_) async => electronicsOnly);

    await controller.selectCategory('electronics');
    final state = controller.state;

    expect(state.selectedCategory, 'electronics');
    expect(state.products.length, electronicsOnly.length);
  });
}
