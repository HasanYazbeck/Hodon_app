import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/booking/booking_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/enums/booking_status.dart';
import '../../../domain/models/booking.dart';
import '../../shared/widgets/shared_widgets.dart';

class BookingListScreen extends ConsumerWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(parentBookingsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Active'),
              Tab(text: 'Past'),
            ],
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (bookings) => TabBarView(
            children: [
              _BookingTab(
                  bookings: bookings
                      .where((b) =>
                          b.status == BookingStatus.pending ||
                          b.status == BookingStatus.accepted ||
                          b.status == BookingStatus.parentConfirmed)
                      .toList()),
              _BookingTab(
                  bookings: bookings.where((b) => b.status.isActive).toList()),
              _BookingTab(
                  bookings: bookings.where((b) => b.status.isPast).toList(),
                  isPast: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingTab extends StatelessWidget {
  final List<Booking> bookings;
  final bool isPast;

  const _BookingTab({required this.bookings, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_rounded,
        title: isPast ? 'No past bookings' : 'No upcoming bookings',
        subtitle: isPast
            ? 'Your booking history will appear here'
            : 'Book a sitter to get started',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.pageHorizontal),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (_, i) => _BookingListItem(booking: bookings[i]),
    );
  }
}

class _BookingListItem extends StatelessWidget {
  final Booking booking;
  const _BookingListItem({required this.booking});

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;
    final hintColor = context.appTextHint;

    return HodonCard(
      onTap: () => context.push('/parent/booking/${booking.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                imageUrl: booking.sitterUser?.avatarUrl,
                name: booking.sitterUser?.fullName ?? 'Sitter',
                size: 44,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.sitterUser?.fullName ?? 'Babysitter',
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(booking.serviceType.label,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: secondaryTextColor)),
                  ],
                ),
              ),
              StatusChip(
                  label: booking.status.label,
                  color: _statusColor(booking.status)),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 14, color: hintColor),
              const SizedBox(width: 4),
              Text(_fmtDate(booking.startDatetime),
                  style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(
                '\$${booking.pricing.total.toStringAsFixed(0)}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus s) {
    if (s.isActive) return AppColors.success;
    if (s == BookingStatus.pending) return AppColors.warning;
    if (s.isPast && s != BookingStatus.completed && s != BookingStatus.rated) {
      return Colors.grey;
    }
    if (s == BookingStatus.completed || s == BookingStatus.rated) {
      return AppColors.success;
    }
    return AppColors.primary;
  }

  String _fmtDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(parentBookingsProvider);

    return bookingsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (bookings) {
        final booking = bookings.where((b) => b.id == bookingId).firstOrNull;
        if (booking == null) {
          return const Scaffold(body: Center(child: Text('Booking not found')));
        }
        return _BookingDetailView(booking: booking);
      },
    );
  }
}

class _BookingDetailView extends ConsumerWidget {
  final Booking booking;
  const _BookingDetailView({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(bookingActionProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _goToBookings(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => _goToBookings(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Column(
                  children: [
                    Text(booking.status.label,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('Booking #${booking.id.substring(0, 8)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Sitter info
              _DetailSection(
                title: 'Babysitter',
                child: Row(
                  children: [
                    UserAvatar(
                        imageUrl: booking.sitterUser?.avatarUrl,
                        name: booking.sitterUser?.fullName,
                        size: 52),
                    const SizedBox(width: AppSizes.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.sitterUser?.fullName ?? 'Sitter',
                            style: Theme.of(context).textTheme.titleMedium),
                        TextButton.icon(
                          onPressed: () =>
                              context.go('/chat/conv_${booking.sitterId}'),
                          icon: const Icon(Icons.chat_bubble_outline_rounded,
                              size: 14),
                          label: const Text('Message'),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, minimumSize: Size.zero),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Date/Time
              _DetailSection(
                title: 'Date & Time',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(Icons.calendar_today_rounded,
                        _fmtDate(booking.startDatetime)),
                    _InfoRow(Icons.schedule_rounded,
                        '${booking.durationHours.toStringAsFixed(1)} hours'),
                  ],
                ),
              ),

              // Location
              _DetailSection(
                title: 'Location',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                        Icons.location_on_rounded, booking.location.fullAddress),
                    const SizedBox(height: AppSizes.sm),
                    _InfoRow(
                      Icons.swap_horiz_rounded,
                      booking.careLocationType.label,
                    ),
                  ],
                ),
              ),

              // Pricing
              _DetailSection(
                title: 'Payment Summary',
                child: Column(
                  children: [
                    _PriceRow('Subtotal',
                        '\$${booking.pricing.subtotal.toStringAsFixed(2)}'),
                    _PriceRow('Platform Fee',
                        '\$${booking.pricing.platformCommission.toStringAsFixed(2)}'),
                    if (booking.pricing.transportFee > 0)
                      _PriceRow('Transport Fee',
                          '\$${booking.pricing.transportFee.toStringAsFixed(2)}'),
                    if (booking.pricing.emergencyFee > 0)
                      _PriceRow('Emergency Fee',
                          '\$${booking.pricing.emergencyFee.toStringAsFixed(2)}',
                          color: AppColors.emergency),
                    const Divider(),
                    _PriceRow('Total',
                        '\$${booking.pricing.total.toStringAsFixed(2)}',
                        isBold: true, color: AppColors.primary),
                    if (booking.platformFeeDeductedOnCancellation) ...[
                      _PriceRow(
                        'Platform Fee Deducted',
                        '-\$${booking.deductedPlatformFeeAmount.toStringAsFixed(2)}',
                        color: AppColors.error,
                      ),
                      _PriceRow(
                        'Refund Amount',
                        '\$${_refundableAmount(booking).toStringAsFixed(2)}',
                        color: AppColors.success,
                      ),
                    ],
                    _PriceRow('Payment', booking.pricing.paymentMethod.label),
                  ],
                ),
              ),

              if (booking.status.canCancelByParent) ...[
                const SizedBox(height: AppSizes.lg),
                OutlinedButton(
                  onPressed: actionState is AsyncLoading
                      ? null
                      : () => _showCancelDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize:
                        const Size(double.infinity, AppSizes.buttonHeight),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
                  ),
                  child: Text(
                    booking.status
                            .requiresPlatformFeeDeductionOnParentCancellation
                        ? 'Cancel Booking (Platform Fee Deduction)'
                        : 'Cancel Booking',
                  ),
                ),
                if (booking.status
                    .requiresPlatformFeeDeductionOnParentCancellation) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'If you cancel after acceptance, the platform fee '
                    '(\$${booking.pricing.platformCommission.toStringAsFixed(2)}) is deducted from the initial payment.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.error),
                  ),
                ],
              ],
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _goToBookings(BuildContext context) {
    context.go('/parent/bookings');
  }

  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _CancelDialog(booking: booking),
    );
    if (reason != null) {
      await ref.read(bookingActionProvider.notifier).cancel(booking.id, reason);
      if (context.mounted) ref.invalidate(parentBookingsProvider);
    }
  }

  String _fmtDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }

  double _refundableAmount(Booking booking) {
    final amount = booking.pricing.total - booking.deductedPlatformFeeAmount;
    return amount < 0 ? 0 : amount;
  }
}

class _CancelDialog extends StatefulWidget {
  final Booking booking;
  const _CancelDialog({required this.booking});

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.booking.status
                .requiresPlatformFeeDeductionOnParentCancellation) ...[
              Text(
                'This booking is already accepted. Cancelling now deducts the platform fee '
                '(\$${widget.booking.pricing.platformCommission.toStringAsFixed(2)}) from the initial payment.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSizes.sm),
            ],
            TextField(
              controller: _ctrl,
              decoration:
                  const InputDecoration(hintText: 'Reason for cancellation...'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Booking')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context,
                _ctrl.text.isEmpty ? 'Cancelled by parent' : _ctrl.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Booking'),
          ),
        ],
      );
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.md),
        child: HodonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: context.appTextSecondary)),
              const SizedBox(height: AppSizes.sm),
              child,
            ],
          ),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(icon, size: 16, color: context.appTextHint),
            const SizedBox(width: AppSizes.sm),
            Expanded(
                child:
                    Text(text, style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      );
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  const _PriceRow(this.label, this.value, {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: isBold
                    ? Theme.of(context).textTheme.titleSmall
                    : Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: context.appTextSecondary)),
            Text(value,
                style: (isBold
                        ? Theme.of(context).textTheme.titleSmall
                        : Theme.of(context).textTheme.bodySmall)
                    ?.copyWith(
                        color: color,
                        fontWeight: isBold ? FontWeight.w700 : null)),
          ],
        ),
      );
}
