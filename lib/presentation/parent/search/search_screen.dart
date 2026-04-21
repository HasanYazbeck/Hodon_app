import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/sitter/sitter_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/interfaces/i_sitter_repository.dart';
import '../../../domain/models/babysitter_profile.dart';
import '../../../domain/enums/app_enums.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'filter_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSitters());
  }

  void _loadSitters({bool reset = false}) {
    ref.read(sitterSearchProvider.notifier).search(
          lat: 33.8869,
          lng: 35.5131,
          filter: ref.read(sitterFilterProvider),
          reset: reset,
        );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sittersAsync = ref.watch(sitterSearchProvider);
    final filter = ref.watch(sitterFilterProvider);

    ref.listen(sitterFilterProvider, (_, __) => _loadSitters(reset: true));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.searchSitters),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _hasActiveFilters(filter),
              child: const Icon(Icons.tune_rounded),
            ),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(context, filter),
          Expanded(
            child: sittersAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(AppSizes.pageHorizontal),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                itemBuilder: (_, __) => const ShimmerCard(height: 120),
              ),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (sitters) => sitters.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: AppStrings.noSittersFound,
                      subtitle: AppStrings.noSittersSubtitle,
                      action: TextButton(
                        onPressed: () {
                          ref.read(sitterFilterProvider.notifier).state = const SitterFilter();
                        },
                        child: const Text('Clear Filters'),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSizes.pageHorizontal),
                      itemCount: sitters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                      itemBuilder: (_, i) => _SitterListCard(
                        sitter: sitters[i],
                        onTap: () => context.go('/parent/sitter/${sitters[i].user.id}'),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pageHorizontal,
        vertical: AppSizes.sm,
      ),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Search by name or skill...',
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          fillColor: AppColors.surface,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, SitterFilter filter) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
        children: [
          _FilterChip(
            label: AppStrings.verified,
            icon: Icons.verified_rounded,
            isActive: filter.verifiedOnly,
            onTap: () => ref.read(sitterFilterProvider.notifier).state =
                filter.copyWith(verifiedOnly: !filter.verifiedOnly),
          ),
          const SizedBox(width: AppSizes.xs),
          _FilterChip(
            label: 'CPR Trained',
            icon: Icons.health_and_safety_rounded,
            isActive: filter.cprOnly,
            onTap: () => ref.read(sitterFilterProvider.notifier).state =
                filter.copyWith(cprOnly: !filter.cprOnly),
          ),
          const SizedBox(width: AppSizes.xs),
          _FilterChip(
            label: AppStrings.inTrustCircle,
            icon: Icons.people_rounded,
            isActive: filter.trustCircleFirst,
            onTap: () => ref.read(sitterFilterProvider.notifier).state =
                filter.copyWith(trustCircleFirst: !filter.trustCircleFirst),
          ),
          const SizedBox(width: AppSizes.xs),
          _FilterChip(
            label: AppStrings.topRated,
            icon: Icons.star_rounded,
            isActive: filter.sortBy == SitterSortBy.topRated,
            onTap: () => ref.read(sitterFilterProvider.notifier).state =
                filter.copyWith(sortBy: SitterSortBy.topRated),
          ),
          const SizedBox(width: AppSizes.xs),
          _FilterChip(
            label: 'Nearest',
            icon: Icons.near_me_rounded,
            isActive: filter.sortBy == SitterSortBy.nearest,
            onTap: () => ref.read(sitterFilterProvider.notifier).state =
                filter.copyWith(sortBy: SitterSortBy.nearest),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters(SitterFilter f) =>
      f.verifiedOnly || f.cprOnly || f.trustCircleFirst || f.maxHourlyRate != null || f.minRating != null;

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, ctrl) => FilterSheet(scrollController: ctrl),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SitterListCard extends StatelessWidget {
  final SitterCard sitter;
  final VoidCallback onTap;

  const _SitterListCard({required this.sitter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HodonCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(
                imageUrl: sitter.user.avatarUrl,
                name: sitter.user.fullName,
                size: AppSizes.avatarLg,
                showBorder: sitter.isInTrustCircle,
                borderColor: AppColors.badgeTrustCircle,
              ),
              if (sitter.profile.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.badgeVerified,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sitter.user.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '\$${sitter.profile.hourlyRate.toInt()}${AppStrings.perHour}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StarRating(rating: sitter.profile.rating),
                    const SizedBox(width: 4),
                    Text(
                      '(${sitter.profile.reviewsCount})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    if (sitter.distanceKm != null) ...[
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: AppColors.textHint),
                      Text(
                        '${sitter.distanceKm!.toStringAsFixed(1)} km',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (sitter.isInTrustCircle)
                      TrustBadgeChip(
                        label: 'Trust Circle',
                        icon: Icons.people_rounded,
                        color: AppColors.badgeTrustCircle,
                      ),
                    ...sitter.profile.badges.take(2).map((b) => TrustBadgeChip(
                          label: b.label,
                          icon: _badgeIcon(b),
                          color: _badgeColor(b),
                        )),
                  ],
                ),
                if (sitter.user.bio != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    sitter.user.bio!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
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

