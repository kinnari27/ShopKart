import 'package:dio/dio.dart';
import 'package:shop_kart/core/errors/app_exception.dart';
import 'package:shop_kart/features/product/domain/repositories/product_repository.dart';
import 'package:shop_kart/shared/data/datasources/product_local_data_source.dart';
import 'package:shop_kart/shared/data/datasources/product_remote_data_source.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote, this._local);

  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;

  @override
  Future<List<Product>> getProducts({String? category}) async {
    try {
      final products = category == null || category == 'All'
          ? await _remote.getProducts()
          : await _remote.getProductsByCategory(category);
      await _local.cacheProducts(products);
      return products;
    } on DioException catch (_) {
      return _local.getCachedProducts();
    } on CacheException {
      rethrow;
    } catch (error) {
      throw NetworkException('Unable to load products: $error');
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      return await _remote.getProduct(id);
    } catch (error) {
      final cached = _local.getCachedProducts();
      return cached.firstWhere((product) => product.id == id);
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final categories = await _remote.getCategories();
      await _local.cacheCategories(categories);
      return ['All', ...categories];
    } catch (_) {
      return ['All', ..._local.getCachedCategories()];
    }
  }
}
