import 'package:shop_kart/features/product/domain/repositories/product_repository.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class GetProductDetail {
  const GetProductDetail(this._repository);

  final ProductRepository _repository;

  Future<Product> call(int id) => _repository.getProduct(id);
}
