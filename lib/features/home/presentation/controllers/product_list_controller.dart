import 'package:get/get.dart';
import 'package:shop_kart/core/constants/api_constants.dart';
import 'package:shop_kart/features/home/presentation/viewmodels/product_list_state.dart';
import 'package:shop_kart/features/product/domain/usecases/get_categories.dart';
import 'package:shop_kart/features/product/domain/usecases/get_products.dart';
import 'package:shop_kart/injection/injection.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class ProductListController extends GetxController {
  static ProductListController get to => Get.find();

  final GetProducts _getProducts;
  final GetCategories _getCategories;

  ProductListController({
    GetProducts? getProducts,
    GetCategories? getCategories,
  })  : _getProducts = getProducts ?? sl<GetProducts>(),
        _getCategories = getCategories ?? sl<GetCategories>();

  final Rx<ProductListState> _state = const ProductListState().obs;
  ProductListState get state => _state.value;

  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<ProductListState> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final categories = await _getCategories();
      final products = await _getProducts();
      final newState = _buildState(products: products, categories: categories);
      _state.value = newState;
      return newState;
    } catch (e) {
      errorMessage.value = e.toString();
      _state.value = _state.value.copyWith(error: e.toString());
      return _state.value;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProducts() async {
    final current = state;
    try {
      final products = await _getProducts(
        category: current.selectedCategory,
      );
      final categories = await _getCategories();
      _state.value = _buildState(
        products: products,
        categories: categories,
        query: current.query,
        selectedCategory: current.selectedCategory,
      );
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = e.toString();
      _state.value = _state.value.copyWith(error: e.toString());
    }
  }

  Future<void> selectCategory(String category) async {
    final current = state;
    _state.value = current.copyWith(isLoading: true, selectedCategory: category);
    try {
      final products = await _getProducts(category: category);
      _state.value = _buildState(
        products: products,
        categories: current.categories,
        selectedCategory: category,
      );
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = e.toString();
      _state.value = _state.value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void search(String query) {
    final current = state;
    _state.value = _buildState(
      products: current.products,
      categories: current.categories,
      selectedCategory: current.selectedCategory,
      query: query,
    );
  }

  void loadNextPage() {
    final current = state;
    if (current.isLoading || !current.hasMore) return;
    final nextPage = current.page + 1;
    final filtered = _filter(current.products, current.query);
    final visible = filtered.take(nextPage * ApiConstants.pageSize).toList();
    _state.value = current.copyWith(
      visibleProducts: visible,
      page: nextPage,
      hasMore: visible.length < filtered.length,
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

