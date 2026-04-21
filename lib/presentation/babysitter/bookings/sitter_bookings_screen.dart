import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/booking/booking_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/enums/booking_status.dart';
import '../../../domain/models/booking.dart';
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
  final List<Booking> bookings;
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
  final Booking booking;
  final bool isNew;

  const _JobCard({required this.booking, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    return HodonCard(
      onTap: () => context.push('/babysitter/booking-request/${booking.id}'),
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
                    onPressed: () => context.push('/babysitter/booking-request/${booking.id}'),
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

