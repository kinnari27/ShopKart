import 'package:get/get.dart';
import 'package:shop_kart/features/product/domain/usecases/get_product_detail.dart';
import 'package:shop_kart/features/review/domain/entities/review.dart';
import 'package:shop_kart/features/review/domain/repositories/review_repository.dart';
import 'package:shop_kart/injection/injection.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class ProductDetailController extends GetxController {
  final GetProductDetail _getProductDetail;
  final ReviewRepository _reviewRepository;
  final int productId;

  ProductDetailController({
    required this.productId,
    GetProductDetail? getProductDetail,
    ReviewRepository? reviewRepository,
  })  : _getProductDetail = getProductDetail ?? sl<GetProductDetail>(),
        _reviewRepository = reviewRepository ?? sl<ReviewRepository>();

  final Rxn<Product> product = Rxn<Product>();
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxString selectedSize = 'M'.obs;
  final RxList<Review> reviews = <Review>[].obs;

  void selectSize(String size) {
    selectedSize.value = size;
  }

  @override
  void onInit() {
    super.onInit();
    loadProduct();
  }

  void loadReviews() {
    reviews.assignAll(_reviewRepository.getReviews(productId));
  }

  Future<void> loadProduct() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _getProductDetail(productId);
      product.value = result;
      loadReviews();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addReview({
    required double rating,
    required String comment,
    required String userName,
  }) async {
    final newReview = Review(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      userName: userName.trim().isEmpty ? 'Shopper' : userName.trim(),
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );

    await _reviewRepository.addReview(newReview);
    loadReviews();

    // Update product rating and count reactively
    final current = product.value;
    if (current != null) {
      final totalReviews = current.ratingCount + 1;
      final newAverage = ((current.rating * current.ratingCount) + rating) / totalReviews;
      product.value = current.copyWith(
        rating: double.parse(newAverage.toStringAsFixed(1)),
        ratingCount: totalReviews,
      );
    }
  }
}
