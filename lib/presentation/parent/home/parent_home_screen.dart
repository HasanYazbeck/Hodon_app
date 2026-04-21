import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../application/booking/booking_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/enums/booking_status.dart';
import '../../shared/widgets/shared_widgets.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activeBookingsAsync = ref.watch(activeParentBookingsProvider);

    final greeting = _greeting();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(activeParentBookingsProvider),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, greeting, user?.firstName ?? '')),
              SliverToBoxAdapter(child: _buildEmergencyBanner(context)),
              SliverToBoxAdapter(child: _buildQuickActions(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pageHorizontal,
                    vertical: AppSizes.md,
                  ),
                  child: SectionHeader(
                    title: AppStrings.upcomingBookings,
                    actionLabel: AppStrings.viewAll,
                    onAction: () => context.go('/parent/bookings'),
                  ),
                ),
              ),
              activeBookingsAsync.when(
                loading: () => const SliverToBoxAdapter(child: _BookingsShimmer()),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(child: Text(e.toString())),
                ),
                data: (bookings) => bookings.isEmpty
                    ? SliverToBoxAdapter(
                        child: EmptyState(
                          icon: Icons.calendar_today_rounded,
                          title: AppStrings.noUpcomingBookings,
                          subtitle: 'Book a babysitter to get started',
                          action: ElevatedButton(
                            onPressed: () => context.go('/parent/search'),
                            child: const Text('Find a Sitter'),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _BookingCard(booking: bookings[i]),
                          childCount: bookings.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  Widget _buildHeader(BuildContext context, String greeting, String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pageHorizontal, AppSizes.lg, AppSizes.pageHorizontal, AppSizes.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting\n$name 👋',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Find trusted care for your little ones',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.emergency,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pageHorizontal,
        vertical: AppSizes.sm,
      ),
      child: GestureDetector(
        onTap: () => context.go('/parent/search'),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5252), Color(0xFFFF8A80)],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          child: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 32)),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.emergencyBooking,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      AppStrings.emergencyBookingSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pageHorizontal,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          _QuickActionTile(
            icon: Icons.search_rounded,
            label: 'Find Sitter',
            color: AppColors.primary,
            onTap: () => context.go('/parent/search'),
          ),
          const SizedBox(width: AppSizes.sm),
          _QuickActionTile(
            icon: Icons.people_rounded,
            label: 'Trust Circle',
            color: AppColors.badgeTrustCircle,
            onTap: () => context.go('/parent/trust-circle'),
          ),
          const SizedBox(width: AppSizes.sm),
          _QuickActionTile(
            icon: Icons.child_care_rounded,
            label: 'My Children',
            color: AppColors.secondary,
            onTap: () => context.go('/parent/children'),
          ),
          const SizedBox(width: AppSizes.sm),
          _QuickActionTile(
            icon: Icons.history_rounded,
            label: 'History',
            color: AppColors.textSecondary,
            onTap: () => context.go('/parent/bookings'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: AppSizes.iconMd),
              const SizedBox(height: AppSizes.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pageHorizontal,
        vertical: AppSizes.xs,
      ),
      child: HodonCard(
        onTap: () => context.go('/parent/booking/${booking.id}'),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: booking.sitterUser?.avatarUrl,
              name: booking.sitterUser?.fullName,
              size: AppSizes.avatarMd,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.sitterUser?.fullName ?? 'Babysitter',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(booking.startDatetime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            StatusChip(
              label: booking.status.label,
              color: _statusColor(booking.status),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day} · ${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }

  Color _statusColor(BookingStatus s) {
    if (s.isActive) return AppColors.success;
    if (s == BookingStatus.pending) return AppColors.warning;
    if (s.isPast) return AppColors.textHint;
    return AppColors.primary;
  }
}

class _BookingsShimmer extends StatelessWidget {
  const _BookingsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.pageHorizontal,
            vertical: AppSizes.xs,
          ),
          child: ShimmerListTile(),
        ),
      ),
    );
  }
}

