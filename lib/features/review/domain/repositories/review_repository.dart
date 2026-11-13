import 'package:shop_kart/features/review/domain/entities/review.dart';

abstract class ReviewRepository {
  List<Review> getReviews(int productId);
  Future<void> addReview(Review review);
}

