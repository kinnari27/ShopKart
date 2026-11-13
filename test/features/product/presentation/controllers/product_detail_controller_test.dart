import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/product/domain/usecases/get_product_detail.dart';
import 'package:shop_kart/features/product/presentation/controllers/product_detail_controller.dart';
import 'package:shop_kart/features/review/domain/entities/review.dart';
import 'package:shop_kart/features/review/domain/repositories/review_repository.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class MockGetProductDetail extends Mock implements GetProductDetail {}
class MockReviewRepository extends Mock implements ReviewRepository {}

class FakeReview extends Fake implements Review {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeReview());
  });

  late MockGetProductDetail mockGetProductDetail;
  late MockReviewRepository mockReviewRepository;
  late ProductDetailController controller;

  const tProduct = Product(
    id: 1,
    title: 'Test Jacket',
    price: 99.0,
    description: 'A great jacket',
    category: 'clothing',
    image: 'jacket.png',
    rating: 4.0,
    ratingCount: 10,
  );

  final tReview = Review(
    id: 'rev_1',
    productId: 1,
    userName: 'Tester',
    rating: 5.0,
    comment: 'Awesome fit',
    createdAt: DateTime(2026, 11, 13),
  );

  setUp(() {
    mockGetProductDetail = MockGetProductDetail();
    mockReviewRepository = MockReviewRepository();

    when(() => mockGetProductDetail(1)).thenAnswer((_) async => tProduct);
    when(() => mockReviewRepository.getReviews(1)).thenReturn([tReview]);

    controller = ProductDetailController(
      productId: 1,
      getProductDetail: mockGetProductDetail,
      reviewRepository: mockReviewRepository,
    );
  });

  test('onInit should load product and reviews', () async {
    controller.onInit();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(controller.product.value, tProduct);
    expect(controller.reviews, [tReview]);
    expect(controller.isLoading.value, isFalse);
    verify(() => mockGetProductDetail(1)).called(1);
    verify(() => mockReviewRepository.getReviews(1)).called(1);
  });

  test('selectSize should update selectedSize observable', () {
    controller.selectSize('XL');
    expect(controller.selectedSize.value, 'XL');
  });

  test('addReview should save review, reload reviews, and update product rating and count', () async {
    controller.onInit();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    when(() => mockReviewRepository.addReview(any())).thenAnswer((_) async {});
    when(() => mockReviewRepository.getReviews(1)).thenReturn([
      Review(
        id: 'rev_2',
        productId: 1,
        userName: 'New User',
        rating: 5.0,
        comment: 'Super cool',
        createdAt: DateTime(2026, 11, 13),
      ),
      tReview,
    ]);

    await controller.addReview(
      rating: 5.0,
      comment: 'Super cool',
      userName: 'New User',
    );

    verify(() => mockReviewRepository.addReview(any())).called(1);
    expect(controller.reviews.length, 2);
    expect(controller.product.value?.ratingCount, 11);
    expect(controller.product.value?.rating, 4.1);
  });
}
