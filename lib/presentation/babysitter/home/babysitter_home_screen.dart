import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../application/booking/booking_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/communication_service.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/enums/booking_status.dart';
import '../../../domain/models/booking.dart';
import '../../shared/widgets/shared_widgets.dart';

class BabysitterHomeScreen extends ConsumerWidget {
  const BabysitterHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activeJobAsync = ref.watch(activeSitterBookingProvider);
    final bookingsAsync = ref.watch(sitterBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(activeSitterBookingProvider);
            ref.invalidate(sitterBookingsProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, user?.firstName ?? '')),
              // Active job
              activeJobAsync.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (job) => job != null
                    ? SliverToBoxAdapter(child: _buildActiveJobCard(context, job))
                    : const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              // Stats row
              SliverToBoxAdapter(child: _buildStats(context)),
              // New requests
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal, vertical: AppSizes.sm),
                  child: SectionHeader(
                    title: 'New Requests',
                    actionLabel: 'View All',
                    onAction: () => context.go('/babysitter/bookings'),
                  ),
                ),
              ),
              bookingsAsync.when(
                loading: () => const SliverToBoxAdapter(child: Padding(
                  padding: EdgeInsets.all(AppSizes.pageHorizontal),
                  child: ShimmerCard(height: 100),
                )),
                error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (bookings) {
                  final pending = bookings.where((b) => b.status == BookingStatus.pending).toList();
                  if (pending.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.pageHorizontal),
                        child: EmptyState(
                          icon: Icons.inbox_rounded,
                          title: 'No new requests',
                          subtitle: 'New booking requests will appear here',
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _RequestCard(
                        booking: pending[i],
                        onTap: () => context.push('/babysitter/booking-request/${pending[i].id}'),
                      ),
                      childCount: pending.length,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'support_fab',
        backgroundColor: AppColors.primary,
        onPressed: () => _showQuickSupportOptions(context),
        tooltip: 'Quick Support',
        child: const Icon(Icons.help_rounded),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.pageHorizontal, AppSizes.lg, AppSizes.pageHorizontal, AppSizes.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $name 👋', style: Theme.of(context).textTheme.headlineMedium),
                Text('Ready to care today?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            onPressed: () => context.go('/babysitter/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard(BuildContext context, Booking job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal, vertical: AppSizes.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.work_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text('Active Job', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              job.serviceType.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/babysitter/booking-request/${job.id}'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal, vertical: AppSizes.sm),
      child: Row(
        children: [
          _StatCard(label: 'This Month', value: '\$320', icon: Icons.attach_money_rounded, color: AppColors.success),
          const SizedBox(width: AppSizes.sm),
          _StatCard(label: 'Jobs Done', value: '12', icon: Icons.check_circle_rounded, color: AppColors.primary),
          const SizedBox(width: AppSizes.sm),
          _StatCard(label: 'Rating', value: '4.9 ★', icon: Icons.star_rounded, color: AppColors.badgeGold),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
              Text(label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _RequestCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _RequestCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal, vertical: AppSizes.xs),
      child: HodonCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: booking.isEmergency ? AppColors.emergencyContainer : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                booking.isEmergency ? Icons.flash_on_rounded : Icons.calendar_today_rounded,
                color: booking.isEmergency ? AppColors.emergency : AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.isEmergency ? '⚡ Emergency Request' : booking.serviceType.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: booking.isEmergency ? AppColors.emergency : null,
                        ),
                  ),
                  Text(
                    _fmtDate(booking.startDatetime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '\$${booking.pricing.total.toStringAsFixed(0)} total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

  void _showQuickSupportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Get Quick Help',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.md),
            ListTile(
              leading: const Icon(Icons.chat_rounded),
              title: const Text('Chat with Support'),
              subtitle: const Text('Live messaging'),
              onTap: () {
                Navigator.pop(context);
                context.go('/babysitter/chat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_rounded),
              title: const Text('Send Email'),
              subtitle: const Text(CommunicationService.supportEmail),
              onTap: () {
                Navigator.pop(context);
                _sendEmailSupport(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_rounded),
              title: const Text('Call Us'),
              subtitle: const Text(CommunicationService.supportPhoneDisplay),
              onTap: () {
                Navigator.pop(context);
                _callSupport(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message_rounded),
              title: const Text('WhatsApp'),
              subtitle: const Text('Chat via WhatsApp'),
              onTap: () {
                Navigator.pop(context);
                _whatsappSupport(context);
              },
            ),
            const SizedBox(height: AppSizes.md),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmailSupport(BuildContext context) async {
    try {
      await CommunicationService.sendEmail(
        toEmail: CommunicationService.supportEmail,
        subject: 'Hodon Support - Babysitter',
        body: 'Hi Hodon Support,\n\nI need help with...\n\nThank you!',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open email: $e')),
        );
      }
    }
  }

  void _callSupport(BuildContext context) async {
    try {
      await CommunicationService.makePhoneCall(CommunicationService.supportPhone);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open phone dialer: $e')),
        );
      }
    }
  }

  void _whatsappSupport(BuildContext context) async {
    try {
      await CommunicationService.openWhatsApp(
        CommunicationService.supportPhone,
        message: 'Hi Hodon, I need help with...',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp: $e')),
        );
      }
    }
  }
