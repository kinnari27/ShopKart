import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_kart/core/constants/api_constants.dart';
import 'package:shop_kart/features/home/presentation/viewmodels/product_list_state.dart';
import 'package:shop_kart/features/product/domain/repositories/product_repository.dart';
import 'package:shop_kart/features/product/domain/usecases/get_categories.dart';
import 'package:shop_kart/features/product/domain/usecases/get_products.dart';
import 'package:shop_kart/injection/injection.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) => sl());
final getProductsUseCaseProvider = Provider<GetProducts>((ref) => sl());
final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) => sl());

final productListViewModelProvider =
    AsyncNotifierProvider<ProductListViewModel, ProductListState>(
      ProductListViewModel.new,
    );

class ProductListViewModel extends AsyncNotifier<ProductListState> {
  GetProducts get _getProducts => ref.read(getProductsUseCaseProvider);
  GetCategories get _getCategories => ref.read(getCategoriesUseCaseProvider);

  @override
  Future<ProductListState> build() async {
    final categories = await _getCategories();
    final products = await _getProducts();
    return _buildState(products: products, categories: categories);
  }

  Future<void> refresh() async {
    final current = state.value ?? const ProductListState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final products = await _getProducts(
        category: current.selectedCategory,
      );
      final categories = await _getCategories();
      return _buildState(
        products: products,
        categories: categories,
        query: current.query,
        selectedCategory: current.selectedCategory,
      );
    });
  }

  Future<void> selectCategory(String category) async {
    final current = state.value ?? const ProductListState();
    state = AsyncData(
      current.copyWith(isLoading: true, selectedCategory: category),
    );
    state = await AsyncValue.guard(() async {
      final products = await _getProducts(category: category);
      return _buildState(
        products: products,
        categories: current.categories,
        selectedCategory: category,
      );
    });
  }

  void search(String query) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      _buildState(
        products: current.products,
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        query: query,
      ),
    );
  }

  void loadNextPage() {
    final current = state.value;
    if (current == null || current.isLoading || !current.hasMore) return;
    final nextPage = current.page + 1;
    final filtered = _filter(current.products, current.query);
    final visible = filtered.take(nextPage * ApiConstants.pageSize).toList();
    state = AsyncData(
      current.copyWith(
        visibleProducts: visible,
        page: nextPage,
        hasMore: visible.length < filtered.length,
      ),
    );
  }

  ProductListState _buildState({
    required List<Product> products,
    required List<String> categories,
    String selectedCategory = 'All',
    String query = '',
  }) {
    final filtered = _filter(products, query);
    final visible = filtered.take(ApiConstants.pageSize).toList();
    return ProductListState(
      products: products,
      visibleProducts: visible,
      categories: categories,
      selectedCategory: selectedCategory,
      query: query,
      hasMore: visible.length < filtered.length,
    );
  }

  List<Product> _filter(List<Product> products, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return products;
    return products
        .where(
          (product) =>
              product.title.toLowerCase().contains(normalized) ||
              product.category.toLowerCase().contains(normalized),
        )
        .toList();
  }
}
