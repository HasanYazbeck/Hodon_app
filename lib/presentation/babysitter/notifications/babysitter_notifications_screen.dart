import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../shared/widgets/shared_widgets.dart';

class BabysitterNotificationsScreen extends StatefulWidget {
  const BabysitterNotificationsScreen({super.key});

  @override
  State<BabysitterNotificationsScreen> createState() =>
      _BabysitterNotificationsScreenState();
}

enum _NotificationTypeFilter { all, booking, message, reminder, review }

enum _DateFilter { all, today, last7Days, last30Days }

class _BabysitterNotificationsScreenState
    extends State<BabysitterNotificationsScreen> {
  late final List<_BabysitterNotification> _notifications;
  _NotificationTypeFilter _selectedType = _NotificationTypeFilter.all;
  _DateFilter _selectedDate = _DateFilter.all;

  @override
  void initState() {
    super.initState();
    _notifications = _seedNotifications
        .map((n) => _BabysitterNotification(
              title: n.title,
              body: n.body,
              createdAt: n.createdAt,
              unread: n.unread,
              icon: n.icon,
              color: n.color,
              type: n.type,
            ))
        .toList();
  }

  List<_BabysitterNotification> get _filteredNotifications {
    final now = DateTime.now();

    return _notifications.where((n) {
      final matchesType = _selectedType == _NotificationTypeFilter.all ||
          n.type == _selectedType;

      final matchesDate = switch (_selectedDate) {
        _DateFilter.all => true,
        _DateFilter.today =>
          n.createdAt.year == now.year &&
              n.createdAt.month == now.month &&
              n.createdAt.day == now.day,
        _DateFilter.last7Days =>
          n.createdAt.isAfter(now.subtract(const Duration(days: 7))),
        _DateFilter.last30Days =>
          n.createdAt.isAfter(now.subtract(const Duration(days: 30))),
      };

      return matchesType && matchesDate;
    }).toList();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  String _dateFilterLabel(_DateFilter f) {
    return switch (f) {
      _DateFilter.all => 'All dates',
      _DateFilter.today => 'Today',
      _DateFilter.last7Days => 'Last 7 days',
      _DateFilter.last30Days => 'Last 30 days',
    };
  }

  String _typeLabel(_NotificationTypeFilter t) {
    return switch (t) {
      _NotificationTypeFilter.all => 'All',
      _NotificationTypeFilter.booking => 'Bookings',
      _NotificationTypeFilter.message => 'Messages',
      _NotificationTypeFilter.reminder => 'Reminders',
      _NotificationTypeFilter.review => 'Reviews',
    };
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;
    final secondaryTextColor = context.appTextSecondary;
    final hintColor = context.appTextHint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (final n in _notifications) {
                  n.unread = false;
                }
              });
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pageHorizontal,
              AppSizes.sm,
              AppSizes.pageHorizontal,
              AppSizes.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: _NotificationTypeFilter.values.map((t) {
                    return ChoiceChip(
                      label: Text(_typeLabel(t)),
                      selected: _selectedType == t,
                      onSelected: (_) => setState(() => _selectedType = t),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Icon(Icons.filter_alt_rounded,
                        size: 18, color: secondaryTextColor),
                    const SizedBox(width: 6),
                    Text('Date:',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: secondaryTextColor)),
                    const SizedBox(width: 8),
                    DropdownButton<_DateFilter>(
                      value: _selectedDate,
                      underline: const SizedBox.shrink(),
                      items: _DateFilter.values
                          .map((d) => DropdownMenuItem<_DateFilter>(
                                value: d,
                                child: Text(_dateFilterLabel(d)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedDate = v);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications',
              subtitle: 'No notifications match your current filters.',
            )
          : ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = filtered[i];
                final isUnread = n.unread;
                return ListTile(
                  tileColor:
                      isUnread ? AppColors.primaryContainer.withValues(alpha: 0.35) : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pageHorizontal,
                    vertical: AppSizes.xs,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: n.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(n.icon, color: n.color, size: 20),
                  ),
                  title: Text(
                    n.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        n.body,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(height: 1.35),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _timeAgo(n.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: hintColor),
                      ),
                    ],
                  ),
                  trailing: isUnread
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BabysitterNotification {
  final String title;
  final String body;
  final DateTime createdAt;
  bool unread;
  final IconData icon;
  final Color color;
  final _NotificationTypeFilter type;

  _BabysitterNotification({
    required this.title,
    required this.body,
    required this.createdAt,
    required this.unread,
    required this.icon,
    required this.color,
    required this.type,
  });
}

final List<_BabysitterNotification> _seedNotifications = [
  _BabysitterNotification(
    title: 'New Booking Request',
    body: 'A parent requested babysitting for tomorrow at 5:00 PM.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    unread: true,
    icon: Icons.work_rounded,
    color: AppColors.primary,
    type: _NotificationTypeFilter.booking,
  ),
  _BabysitterNotification(
    title: 'Booking Accepted',
    body: 'Your booking with Nour S. was confirmed by the parent.',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    unread: true,
    icon: Icons.check_circle_rounded,
    color: AppColors.success,
    type: _NotificationTypeFilter.booking,
  ),
  _BabysitterNotification(
    title: 'New Message',
    body: 'You received a new message from a parent.',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    unread: true,
    icon: Icons.chat_bubble_rounded,
    color: AppColors.primary,
    type: _NotificationTypeFilter.message,
  ),
  _BabysitterNotification(
    title: 'Check-In Reminder',
    body: 'You have a booking starting in 30 minutes.',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    unread: false,
    icon: Icons.alarm_rounded,
    color: AppColors.warning,
    type: _NotificationTypeFilter.reminder,
  ),
  _BabysitterNotification(
    title: 'Review Received',
    body: 'You received a new 5-star review from a parent.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    unread: false,
    icon: Icons.star_rounded,
    color: AppColors.badgeGold,
    type: _NotificationTypeFilter.review,
  ),
];

