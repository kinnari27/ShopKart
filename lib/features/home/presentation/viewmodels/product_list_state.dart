import 'package:shop_kart/shared/domain/entities/product.dart';

class ProductListState {
  const ProductListState({
    this.products = const [],
    this.visibleProducts = const [],
    this.categories = const ['All'],
    this.selectedCategory = 'All',
    this.query = '',
    this.page = 1,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  final List<Product> products;
  final List<Product> visibleProducts;
  final List<String> categories;
  final String selectedCategory;
  final String query;
  final int page;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  ProductListState copyWith({
    List<Product>? products,
    List<Product>? visibleProducts,
    List<String>? categories,
    String? selectedCategory,
    String? query,
    int? page,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return ProductListState(
      products: products ?? this.products,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      query: query ?? this.query,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}
