import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../shared/widgets/shared_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all read')),
        ],
      ),
      body: _mockNotifications.isEmpty
          ? const EmptyState(icon: Icons.notifications_none_rounded, title: 'No notifications', subtitle: 'You\'re all caught up!')
          : ListView.separated(
              itemCount: _mockNotifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = _mockNotifications[i];
                final isUnread = n['unread'] as bool;
                return ListTile(
                  tileColor: isUnread ? AppColors.primaryContainer.withValues(alpha: 0.4) : null,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (n['color'] as Color).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 20),
                  ),
                  title: Text(n['title'] as String, style: Theme.of(context).textTheme.titleSmall),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['body'] as String, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
                      Text(n['time'] as String, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.appTextHint)),
                    ],
                  ),
                  trailing: isUnread ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)) : null,
                );
              },
            ),
    );
  }

  static final _mockNotifications = [
    {'title': 'Booking Accepted', 'body': 'Lara Haddad accepted your booking for tomorrow.', 'time': '2 hours ago', 'unread': true, 'icon': Icons.check_circle_rounded, 'color': AppColors.success},
    {'title': 'New Message', 'body': 'Rima Azar sent you a message.', 'time': '5 hours ago', 'unread': true, 'icon': Icons.chat_bubble_rounded, 'color': AppColors.primary},
    {'title': 'Booking Reminder', 'body': 'Your booking starts in 24 hours.', 'time': '1 day ago', 'unread': false, 'icon': Icons.alarm_rounded, 'color': AppColors.warning},
    {'title': 'Rate Your Experience', 'body': 'How was your session with Rima Azar?', 'time': '3 days ago', 'unread': false, 'icon': Icons.star_rounded, 'color': AppColors.badgeGold},
  ];
}

