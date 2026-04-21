import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../shared/widgets/shared_widgets.dart';

enum _ReviewsDateFilter { all, last7Days, last30Days, last90Days }

enum _ReviewsRatingFilter { all, range40to44, range45to49, exact50 }

class MyReviewsScreen extends ConsumerStatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  ConsumerState<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends ConsumerState<MyReviewsScreen> {
  _ReviewsDateFilter _dateFilter = _ReviewsDateFilter.all;
  _ReviewsRatingFilter _ratingFilter = _ReviewsRatingFilter.all;

  List<_ReviewItem> _applyFilters(List<_ReviewItem> source) {
    final now = DateTime.now();

    return source.where((r) {
      final dateOk = switch (_dateFilter) {
        _ReviewsDateFilter.all => true,
        _ReviewsDateFilter.last7Days => r.createdAt.isAfter(now.subtract(const Duration(days: 7))),
        _ReviewsDateFilter.last30Days => r.createdAt.isAfter(now.subtract(const Duration(days: 30))),
        _ReviewsDateFilter.last90Days => r.createdAt.isAfter(now.subtract(const Duration(days: 90))),
      };

      final ratingOk = switch (_ratingFilter) {
        _ReviewsRatingFilter.all => true,
        _ReviewsRatingFilter.range40to44 => r.rating >= 4.0 && r.rating < 4.5,
        _ReviewsRatingFilter.range45to49 => r.rating >= 4.5 && r.rating < 5.0,
        _ReviewsRatingFilter.exact50 => r.rating == 5.0,
      };

      return dateOk && ratingOk;
    }).toList();
  }

  String _dateFilterLabel(_ReviewsDateFilter f) {
    return switch (f) {
      _ReviewsDateFilter.all => 'All dates',
      _ReviewsDateFilter.last7Days => 'Last 7 days',
      _ReviewsDateFilter.last30Days => 'Last 30 days',
      _ReviewsDateFilter.last90Days => 'Last 90 days',
    };
  }

  String _ratingFilterLabel(_ReviewsRatingFilter f) {
    return switch (f) {
      _ReviewsRatingFilter.all => 'All',
      _ReviewsRatingFilter.range40to44 => '4.0-4.4',
      _ReviewsRatingFilter.range45to49 => '4.5-4.9',
      _ReviewsRatingFilter.exact50 => '5.0',
    };
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _applyFilters(_mockReviews);
    final avgRating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Reviews')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
            HodonCard(
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(Icons.star_rounded, color: AppColors.badgeGold, size: 28),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overall Rating', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          '${avgRating.toStringAsFixed(1)} • ${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  StarRating(rating: avgRating, size: 16),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                const Icon(Icons.filter_alt_rounded, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<_ReviewsDateFilter>(
                    value: _dateFilter,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    items: _ReviewsDateFilter.values
                        .map((d) => DropdownMenuItem(value: d, child: Text(_dateFilterLabel(d))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _dateFilter = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: _ReviewsRatingFilter.values
                  .map(
                    (r) => ChoiceChip(
                      label: Text(_ratingFilterLabel(r)),
                      selected: _ratingFilter == r,
                      onSelected: (_) => setState(() => _ratingFilter = r),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Recent Reviews', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            if (reviews.isEmpty)
              const EmptyState(
                icon: Icons.reviews_rounded,
                title: 'No reviews yet',
                subtitle: 'Completed bookings will appear here as feedback from parents.',
              )
            else
              ...reviews.map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: HodonCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            UserAvatar(name: review.parentName, size: 40),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.parentName,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    review.dateLabel,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                              ),
                              child: Text(
                                '${review.rating.toStringAsFixed(1)} ★',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem {
  final String parentName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const _ReviewItem({
    required this.parentName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  String get dateLabel {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 14) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays >= 1) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inHours >= 1) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    return '${diff.inMinutes} min ago';
  }
}

final List<_ReviewItem> _mockReviews = [
  _ReviewItem(
    parentName: 'Maya N.',
    rating: 5.0,
    comment: 'Very kind and professional. My daughter felt comfortable right away.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  _ReviewItem(
    parentName: 'Rami K.',
    rating: 4.8,
    comment: 'On time, great communication, and followed all routines perfectly.',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  _ReviewItem(
    parentName: 'Nour S.',
    rating: 4.9,
    comment: 'Excellent care and engaging activities. Highly recommended.',
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
  _ReviewItem(
    parentName: 'Dina A.',
    rating: 4.2,
    comment: 'Very caring and patient with my toddler. Would book again.',
    createdAt: DateTime.now().subtract(const Duration(days: 25)),
  ),
  _ReviewItem(
    parentName: 'Karim H.',
    rating: 4.0,
    comment: 'Helpful and communicative. Session went smoothly.',
    createdAt: DateTime.now().subtract(const Duration(days: 40)),
  ),
];

