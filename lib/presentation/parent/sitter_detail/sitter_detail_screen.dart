import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/sitter/sitter_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/models/models.dart';
import '../../../domain/models/babysitter_profile.dart';
import '../../shared/widgets/shared_widgets.dart';

class SitterDetailScreen extends ConsumerWidget {
  final String sitterId;
  const SitterDetailScreen({super.key, required this.sitterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitterAsync = ref.watch(sitterDetailProvider(sitterId));
    final reviewsAsync = ref.watch(sitterReviewsProvider(sitterId));

    return sitterAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (sitter) => _SitterDetailView(sitter: sitter, reviewsAsync: reviewsAsync),
    );
  }
}

class _SitterDetailView extends StatelessWidget {
  final SitterCard sitter;
  final AsyncValue<List<Review>> reviewsAsync;

  const _SitterDetailView({required this.sitter, required this.reviewsAsync});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.appBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildProfileHeader(context)),
          SliverToBoxAdapter(child: _buildBadges(context)),
          SliverToBoxAdapter(child: _buildStats(context)),
          SliverToBoxAdapter(child: _buildAbout(context)),
          SliverToBoxAdapter(child: _buildServices(context)),
          SliverToBoxAdapter(child: _buildSkills(context)),
          SliverToBoxAdapter(child: _buildAgeGroups(context)),
          SliverToBoxAdapter(child: _buildReviews(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: _buildBookingBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final backgroundColor = context.appBackground;
    final surfaceColor = context.appSurface;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: backgroundColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: surfaceColor,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
            ),
            child: const Icon(Icons.favorite_border_rounded, size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: AppSizes.sm),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            sitter.user.avatarUrl != null
                ? Image.network(sitter.user.avatarUrl!, fit: BoxFit.cover)
                : Container(
                    color: AppColors.primaryContainer,
                    child: const Center(child: Icon(Icons.person_rounded, size: 100, color: AppColors.primary)),
                  ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sitter.user.fullName, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StarRating(rating: sitter.profile.rating, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${sitter.profile.rating.toStringAsFixed(1)} · ${sitter.profile.reviewsCount} reviews',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sitter.profile.completedJobs} jobs completed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${sitter.profile.hourlyRate.toInt()}/hr',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (sitter.profile.averageResponseTime != null)
                    Text(
                      'Responds ${sitter.profile.averageResponseTime}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
          if (sitter.isInTrustCircle) ...[
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'In Your Trust Circle',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadges(BuildContext context) {
    if (sitter.profile.badges.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Wrap(
        spacing: AppSizes.sm,
        runSpacing: AppSizes.sm,
        children: sitter.profile.badges.map((b) => TrustBadgeChip(
              label: b.label,
              icon: _badgeIcon(b),
              color: _badgeColor(b),
            )).toList(),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.pageHorizontal),
      child: Row(
        children: [
          _StatTile(label: 'Experience', value: '${sitter.profile.yearsOfExperience} yrs'),
          _StatTile(label: 'Jobs Done', value: '${sitter.profile.completedJobs}'),
          _StatTile(label: 'Rating', value: sitter.profile.rating.toStringAsFixed(1)),
          _StatTile(
            label: 'Languages',
            value: sitter.profile.languages.length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildAbout(BuildContext context) {
    if (sitter.user.bio == null) return const SizedBox.shrink();
    final secondaryTextColor = context.appTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.sm),
          Text(
            sitter.user.bio!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryTextColor, height: 1.7),
          ),
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }

  Widget _buildServices(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Services Offered', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: sitter.profile.services
                .map((s) => Chip(label: Text(s.label)))
                .toList(),
          ),
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }

  Widget _buildSkills(BuildContext context) {
    if (sitter.profile.skills.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills & Training', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: sitter.profile.skills
                .map((s) => Chip(
                      label: Text(s.label),
                      backgroundColor: AppColors.successContainer,
                      labelStyle: const TextStyle(color: AppColors.success, fontSize: 12),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }

  Widget _buildAgeGroups(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Works With', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            children: sitter.profile.ageGroups
                .map((a) => Chip(label: Text(a.label)))
                .toList(),
          ),
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }

  Widget _buildReviews(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Reviews',
            actionLabel: 'See All',
            onAction: () {},
          ),
          const SizedBox(height: AppSizes.sm),
          reviewsAsync.when(
            loading: () => const ShimmerCard(height: 80),
            error: (_, __) => const SizedBox.shrink(),
            data: (reviews) => Column(
              children: reviews.take(3).map((r) => _ReviewCard(review: r)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/chat/conv_${sitter.user.id}'),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/parent/book/${sitter.user.id}'),
                icon: const Icon(Icons.calendar_today_rounded),
                label: const Text('Book Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _badgeIcon(TrustBadge b) => switch (b) {
        TrustBadge.idVerified => Icons.badge_rounded,
        TrustBadge.backgroundChecked => Icons.security_rounded,
        TrustBadge.cprCertified => Icons.health_and_safety_rounded,
        TrustBadge.videoInterviewed => Icons.videocam_rounded,
        TrustBadge.topRated => Icons.star_rounded,
        TrustBadge.repeatFamilyFavorite => Icons.favorite_rounded,
      };

  Color _badgeColor(TrustBadge b) => switch (b) {
        TrustBadge.idVerified => AppColors.badgeVerified,
        TrustBadge.backgroundChecked => AppColors.info,
        TrustBadge.cprCertified => AppColors.badgeCPR,
        TrustBadge.videoInterviewed => AppColors.primary,
        TrustBadge.topRated => AppColors.badgeGold,
        TrustBadge.repeatFamilyFavorite => AppColors.emergency,
      };
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: AppSizes.sm),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Column(
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      );
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.sm),
        child: HodonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(imageUrl: review.reviewerAvatarUrl, name: review.reviewerName, size: 36),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: Text(review.reviewerName ?? 'Parent', style: Theme.of(context).textTheme.titleSmall)),
                  StarRating(rating: review.overallRating, size: 12),
                ],
              ),
              if (review.comment != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(review.comment!, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5)),
              ],
            ],
          ),
        ),
      );
}
