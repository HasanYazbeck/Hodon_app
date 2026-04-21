import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../shared/widgets/shared_widgets.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.messages)),
      body: _mockConversations.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: AppStrings.noConversations,
              subtitle: AppStrings.noConversationsSubtitle,
            )
          : ListView.separated(
              itemCount: _mockConversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (_, i) {
                final c = _mockConversations[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal, vertical: AppSizes.sm),
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      UserAvatar(
                        imageUrl: c['avatarUrl'] as String?,
                        name: c['name'] as String?,
                        size: AppSizes.avatarMd,
                      ),
                      if (c['unread'] as int > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: Center(child: Text('${c['unread']}', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700))),
                          ),
                        ),
                    ],
                  ),
                  title: Text(c['name'] as String, style: Theme.of(context).textTheme.titleSmall),
                  subtitle: Text(
                    c['lastMessage'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: (c['unread'] as int) > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: (c['unread'] as int) > 0 ? FontWeight.w600 : null,
                        ),
                  ),
                  trailing: Text(c['time'] as String, style: Theme.of(context).textTheme.labelSmall),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversationId: c['id'] as String))),
                );
              },
            ),
    );
  }

  static const _mockConversations = [
    {'id': 'conv_sitter_1', 'name': 'Lara Haddad', 'avatarUrl': 'https://i.pravatar.cc/150?img=47', 'lastMessage': 'See you tomorrow at 2pm!', 'time': '2h', 'unread': 2},
    {'id': 'conv_sitter_3', 'name': 'Rima Azar', 'avatarUrl': 'https://i.pravatar.cc/150?img=44', 'lastMessage': 'All confirmed, thanks!', 'time': '1d', 'unread': 0},
  ];
}

class ChatScreen extends StatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {'id': '1', 'text': 'Hi! I can confirm the booking for tomorrow.', 'isMe': false, 'time': '2:10 PM'},
    {'id': '2', 'text': 'Great, thanks! The kids are excited 😊', 'isMe': true, 'time': '2:12 PM'},
    {'id': '3', 'text': 'See you tomorrow at 2pm!', 'isMe': false, 'time': '2:15 PM'},
  ];

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'id': DateTime.now().toString(), 'text': _ctrl.text.trim(), 'isMe': true, 'time': 'Now'});
      _ctrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(imageUrl: 'https://i.pravatar.cc/150?img=47', size: 36),
            const SizedBox(width: AppSizes.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lara Haddad', style: Theme.of(context).textTheme.titleSmall),
                Text('Babysitter', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Safety banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
            color: AppColors.warningContainer,
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, size: 14, color: AppColors.warning),
                const SizedBox(width: 6),
                Expanded(child: Text(AppStrings.safetyNote, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.warning))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isMe = m['isMe'] as bool;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMe) ...[
                        UserAvatar(imageUrl: 'https://i.pravatar.cc/150?img=47', size: 28),
                        const SizedBox(width: 6),
                      ],
                      Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.bubbleSent : AppColors.bubbleReceived,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 16),
                              ),
                            ),
                            child: Text(
                              m['text'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: isMe ? Colors.white : AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(m['time'] as String, style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.sm, AppSizes.sm + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: AppStrings.typeAMessage,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusFull), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

