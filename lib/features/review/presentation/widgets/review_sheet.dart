import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/features/auth/presentation/controllers/auth_controller.dart';
import 'package:shop_kart/features/product/presentation/controllers/product_detail_controller.dart';
import 'package:shop_kart/features/review/domain/entities/review.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

abstract final class ReviewSheet {
  static void showReviews(
    BuildContext context,
    ProductDetailController controller,
    Product product,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          return Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer Reviews',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Obx(() {
                  final reviews = controller.reviews;
                  final currentProduct = controller.product.value ?? product;

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Rating summary header card
                      _buildRatingSummaryCard(context, currentProduct, reviews),
                      const SizedBox(height: 16),

                      // Add review button row
                      FilledButton.tonalIcon(
                        onPressed: () {
                          if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                          showAddReview(context, controller, currentProduct);
                        },
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Write a Review'),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'All Reviews (${reviews.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (reviews.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No reviews yet',
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Be the first to review this product!',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...reviews.map((r) => _buildReviewCard(context, r)),
                    ],
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showAddReview(
    BuildContext context,
    ProductDetailController controller,
    Product product,
  ) {
    final theme = Theme.of(context);
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;
    final defaultName = authController?.currentUser.value?.name ?? '';

    final nameController = TextEditingController(text: defaultName);
    final commentController = TextEditingController();
    final RxDouble ratingValue = 5.0.obs;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Write a Review',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Product teaser card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: product.image,
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) => const Icon(Icons.image),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Interactive Star Rating Selector
                Text(
                  'Your Overall Rating',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final current = ratingValue.value;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          final isFilled = current >= star;
                          return IconButton(
                            iconSize: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            icon: Icon(
                              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: isFilled ? Colors.amber.shade700 : theme.colorScheme.outlineVariant,
                            ),
                            onPressed: () => ratingValue.value = star.toDouble(),
                          );
                        }),
                      ),
                      Text(
                        _getRatingLabel(current),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),

                // Reviewer Name field
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Review Comment field
                TextFormField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Your Review',
                    hintText: 'What did you like or dislike? How was the quality and fit?',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write a review comment';
                    }
                    if (value.trim().length < 5) {
                      return 'Review comment must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                FilledButton.icon(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      await controller.addReview(
                        rating: ratingValue.value,
                        comment: commentController.text,
                        userName: nameController.text,
                      );
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                      Get.snackbar(
                        'Review Submitted! ⭐',
                        'Thank you for reviewing "${product.title}". Your feedback helps other shoppers!',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Submit Review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildRatingSummaryCard(
    BuildContext context,
    Product product,
    List<Review> reviews,
  ) {
    final theme = Theme.of(context);
    final count = reviews.isNotEmpty ? reviews.length : product.ratingCount;
    final rating = reviews.isNotEmpty
        ? reviews.fold(0.0, (s, r) => s + r.rating) / reviews.length
        : product.rating;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(60),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final isFilled = rating >= index + 1;
                  final isHalf = rating > index && rating < index + 1;
                  return Icon(
                    isFilled
                        ? Icons.star_rounded
                        : (isHalf ? Icons.star_half_rounded : Icons.star_outline_rounded),
                    color: Colors.amber.shade700,
                    size: 18,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                'Based on $count reviews',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Verified Buyers',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildReviewCard(BuildContext context, Review review) {
    final theme = Theme.of(context);
    final initial = review.userName.isNotEmpty
        ? review.userName[0].toUpperCase()
        : 'U';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(120),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    final isFilled = review.rating >= index + 1;
                    return Icon(
                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFilled ? Colors.amber.shade700 : theme.colorScheme.outlineVariant,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  static String _getRatingLabel(double rating) {
    if (rating >= 5.0) return '5 Stars - Excellent! 😍';
    if (rating >= 4.0) return '4 Stars - Very Good! 😊';
    if (rating >= 3.0) return '3 Stars - Average 🙂';
    if (rating >= 2.0) return '2 Stars - Below Average 🙁';
    return '1 Star - Terrible 😞';
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
