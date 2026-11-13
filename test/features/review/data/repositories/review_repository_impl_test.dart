import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_kart/features/review/data/repositories/review_repository_impl.dart';
import 'package:shop_kart/features/review/domain/entities/review.dart';

class MockReviewBox extends Mock implements Box<Map> {}

void main() {
  late MockReviewBox mockBox;
  late ReviewRepositoryImpl repository;

  setUp(() {
    mockBox = MockReviewBox();
    repository = ReviewRepositoryImpl(mockBox);
  });

  final tReview = Review(
    id: 'rev_1',
    productId: 10,
    userName: 'John Doe',
    rating: 5.0,
    comment: 'Great product!',
    createdAt: DateTime(2026, 11, 13),
  );

  test('getReviews should return sample reviews when box is empty', () {
    when(() => mockBox.values).thenReturn([]);

    final reviews = repository.getReviews(10);

    expect(reviews, isNotEmpty);
    expect(reviews.first.productId, 10);
  });

  test('getReviews should return stored reviews combined with samples', () {
    when(() => mockBox.values).thenReturn([
      {
        'id': 'rev_custom',
        'productId': 10,
        'userName': 'Alice',
        'rating': 4.5,
        'comment': 'Really liked it',
        'createdAt': '2026-11-13T12:00:00.000',
      }
    ]);

    final reviews = repository.getReviews(10);

    expect(reviews.any((r) => r.id == 'rev_custom'), isTrue);
  });

  test('addReview should save review map to box', () async {
    when(() => mockBox.put('rev_1', any())).thenAnswer((_) async {});

    await repository.addReview(tReview);

    verify(() => mockBox.put('rev_1', any())).called(1);
  });
}

