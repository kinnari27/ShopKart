import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shop_kart/shared/data/models/product_model.dart';

part 'product_remote_data_source.g.dart';

@RestApi()
abstract class ProductRemoteDataSource {
  factory ProductRemoteDataSource(Dio dio) = _ProductRemoteDataSource;

  @GET('/products')
  Future<List<ProductModel>> getProducts();

  @GET('/products/{id}')
  Future<ProductModel> getProduct(@Path('id') int id);

  @GET('/products/categories')
  Future<List<String>> getCategories();

  @GET('/products/category/{category}')
  Future<List<ProductModel>> getProductsByCategory(
    @Path('category') String category,
  );
}
