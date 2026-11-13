import 'package:hive/hive.dart';
import 'package:shop_kart/features/review/data/models/review_model.dart';
import 'package:shop_kart/features/review/domain/entities/review.dart';
import 'package:shop_kart/features/review/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final Box<Map> _box;

  ReviewRepositoryImpl(this._box);

  @override
  List<Review> getReviews(int productId) {
    final stored = _box.values
        .whereType<Map>()
        .map((e) => ReviewModel.fromJson(e))
        .where((r) => r.productId == productId)
        .toList();

    // If no custom reviews stored yet for this product, provide initial sample reviews
    if (stored.isEmpty) {
      return _generateSampleReviews(productId);
    }

    // Combine user submitted reviews with samples so there's always rich content
    final sampleIds = _generateSampleReviews(productId).map((s) => s.id).toSet();
    final combined = [
      ...stored,
      ..._generateSampleReviews(productId).where((s) => !sampleIds.contains(s.id)),
    ];
    combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return combined;
  }

  @override
  Future<void> addReview(Review review) async {
    final model = review is ReviewModel
        ? review
        : ReviewModel(
            id: review.id,
            productId: review.productId,
            userName: review.userName,
            rating: review.rating,
            comment: review.comment,
            createdAt: review.createdAt,
          );
    await _box.put(review.id, model.toJson());
  }

  List<Review> _generateSampleReviews(int productId) {
    final baseTime = DateTime.now().subtract(const Duration(days: 2));
    return [
      Review(
        id: 'seed_${productId}_1',
        productId: productId,
        userName: 'Sarah Jenkins',
        rating: 5.0,
        comment: 'Absolutely love the build quality! Shipped quickly and looks even better in real life.',
        createdAt: baseTime.subtract(const Duration(days: 1)),
      ),
      Review(
        id: 'seed_${productId}_2',
        productId: productId,
        userName: 'Michael Chen',
        rating: 4.0,
        comment: 'Great value for money. Exactly as described in the product catalog.',
        createdAt: baseTime.subtract(const Duration(days: 5)),
      ),
      Review(
        id: 'seed_${productId}_3',
        productId: productId,
        userName: 'Emma Watson',
        rating: 4.5,
        comment: 'Very satisfied with my purchase. Will definitely recommend to friends.',
        createdAt: baseTime.subtract(const Duration(days: 9)),
      ),
    ];
  }
}

