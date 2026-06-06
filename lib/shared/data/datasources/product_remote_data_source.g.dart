// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file

part of 'product_remote_data_source.dart';

class _ProductRemoteDataSource implements ProductRemoteDataSource {
  _ProductRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _dio.get<List<dynamic>>('/products');
    return response.data!
        .map(
          (json) =>
              ProductModel.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/products/$id');
    return ProductModel.fromJson(response.data!);
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await _dio.get<List<dynamic>>('/products/categories');
    return response.data!.cast<String>();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final response = await _dio.get<List<dynamic>>(
      '/products/category/$category',
    );
    return response.data!
        .map(
          (json) =>
              ProductModel.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }
}
