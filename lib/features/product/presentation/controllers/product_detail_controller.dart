import 'package:get/get.dart';
import 'package:shop_kart/features/product/domain/usecases/get_product_detail.dart';
import 'package:shop_kart/injection/injection.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class ProductDetailController extends GetxController {
  final GetProductDetail _getProductDetail;
  final int productId;

  ProductDetailController({
    required this.productId,
    GetProductDetail? getProductDetail,
  }) : _getProductDetail = getProductDetail ?? sl<GetProductDetail>();

  final Rxn<Product> product = Rxn<Product>();
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadProduct();
  }

  Future<void> loadProduct() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _getProductDetail(productId);
      product.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

