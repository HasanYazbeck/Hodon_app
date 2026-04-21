import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/booking/booking_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/enums/booking_status.dart';
import '../../shared/widgets/shared_widgets.dart';

class SitterBookingsScreen extends ConsumerWidget {
  const SitterBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(sitterBookingsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Jobs'),
          bottom: const TabBar(
            tabs: [Tab(text: 'New'), Tab(text: 'Active'), Tab(text: 'Past')],
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (bookings) => TabBarView(
            children: [
              _JobList(
                bookings: bookings.where((b) => b.status == BookingStatus.pending).toList(),
                isNew: true,
              ),
              _JobList(bookings: bookings.where((b) => b.status.isActive).toList()),
              _JobList(bookings: bookings.where((b) => b.status.isPast).toList(), isPast: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobList extends StatelessWidget {
  final List bookings;
  final bool isNew;
  final bool isPast;

  const _JobList({required this.bookings, this.isNew = false, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: isNew ? Icons.inbox_rounded : Icons.work_off_rounded,
        title: isNew ? 'No new requests' : isPast ? 'No past jobs' : 'No active jobs',
        subtitle: isNew ? 'New booking requests will appear here' : '',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.pageHorizontal),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (_, i) => _JobCard(booking: bookings[i], isNew: isNew),
    );
  }
}

class _JobCard extends StatelessWidget {
  final dynamic booking;
  final bool isNew;

  const _JobCard({required this.booking, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    return HodonCard(
      onTap: () => context.go('/babysitter/booking-request/${booking.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.isEmergency ? '⚡ Emergency' : booking.serviceType.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: booking.isEmergency ? AppColors.emergency : null,
                      ),
                ),
              ),
              StatusChip(
                label: booking.status.label,
                color: booking.status.isActive ? AppColors.success : AppColors.textHint,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(_fmtDate(booking.startDatetime), style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(
                '\$${booking.pricing.total.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (isNew) ...[
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/babysitter/booking-request/${booking.id}'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                    ),
                    child: const Text('View & Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day} · $h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}

class BookingRequestScreen extends ConsumerWidget {
  final String bookingId;
  const BookingRequestScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(sitterBookingsProvider);
    final actionState = ref.watch(bookingActionProvider);

    return bookingsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (bookings) {
        final booking = bookings.where((b) => b.id == bookingId).firstOrNull;
        if (booking == null) return const Scaffold(body: Center(child: Text('Not found')));

        return Scaffold(
          appBar: AppBar(
            title: Text(booking.isEmergency ? '⚡ Emergency Request' : 'Booking Request'),
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pageHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow('Service', booking.serviceType.label),
                _InfoRow('Type', booking.bookingType.label),
                _InfoRow('Date & Time', _fmtDate(booking.startDatetime)),
                _InfoRow('Duration', '${booking.durationHours.toStringAsFixed(1)} hours'),
                _InfoRow('Location', booking.location.fullAddress),
                _InfoRow('Earnings', '\$${(booking.pricing.hourlyRate * booking.durationHours).toStringAsFixed(2)}'),
                if (booking.notes != null) _InfoRow('Notes', booking.notes!),
                const SizedBox(height: AppSizes.xl),
                if (booking.status == BookingStatus.pending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: actionState is AsyncLoading ? null : () async {
                            await ref.read(bookingActionProvider.notifier).reject(bookingId, 'Not available');
                            if (context.mounted) context.pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            minimumSize: const Size(0, AppSizes.buttonHeight),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: actionState is AsyncLoading ? null : () async {
                            await ref.read(bookingActionProvider.notifier).accept(bookingId);
                            if (context.mounted) context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, AppSizes.buttonHeight),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
                          ),
                          child: actionState is AsyncLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Accept Job'),
                        ),
                      ),
                    ],
                  ),
                ] else if (booking.status == BookingStatus.accepted || booking.status == BookingStatus.parentConfirmed) ...[
                  ElevatedButton.icon(
                    onPressed: actionState is AsyncLoading ? null : () async {
                      await ref.read(bookingActionProvider.notifier).checkIn(bookingId);
                      if (context.mounted) ref.invalidate(sitterBookingsProvider);
                    },
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Check In'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
                    ),
                  ),
                ] else if (booking.status == BookingStatus.checkedIn || booking.status == BookingStatus.inProgress) ...[
                  ElevatedButton.icon(
                    onPressed: actionState is AsyncLoading ? null : () async {
                      await ref.read(bookingActionProvider.notifier).checkOut(bookingId);
                      if (context.mounted) ref.invalidate(sitterBookingsProvider);
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Check Out'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                      backgroundColor: AppColors.warning,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmtDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.sm),
        child: HodonCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(label, style: Theme.of(context).textTheme.labelMedium),
              ),
              Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        ),
      );
}

