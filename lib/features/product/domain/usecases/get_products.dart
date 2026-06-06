import 'package:shop_kart/features/product/domain/repositories/product_repository.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class GetProducts {
  const GetProducts(this._repository);
  final ProductRepository _repository;

  Future<List<Product>> call({String? category}) =>
      _repository.getProducts(category: category);
}
