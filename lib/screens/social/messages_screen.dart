import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../providers/auth_provider.dart';
import '../../services/messaging_service.dart';
import '../../widgets/naseem_app_bar.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/premium_states.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: PremiumBackground(
          child: const PremiumEmptyState(
            title: 'Sign in required',
            subtitle: 'Log in to view your messages',
            icon: Icons.lock_outline_rounded,
          ),
        ),
      );
    }

    final service = MessagingService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const NaseemAppBar(title: 'Messages'),
      body: PremiumBackground(
        child: StreamBuilder(
          stream: service.watchConversations(user.uid),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const PremiumLoading(message: 'Loading conversations…');
            }
            final conversations = snap.data!;
            if (conversations.isEmpty) {
              return const PremiumEmptyState(
                title: 'No messages yet',
                subtitle: 'Start a conversation with fellow Muslims',
                icon: Icons.chat_bubble_outline_rounded,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: conversations.length,
              itemBuilder: (_, i) {
                final conv = conversations[i];
                final otherId =
                    conv.participantIds.firstWhere((id) => id != user.uid);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: AppDecorations.glass(opacity: 0.78),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDecorations.radiusXl),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryGreen,
                      child: Text(
                        otherId.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      'User ${otherId.substring(0, 6)}…',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      conv.lastMessage ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: conv.unreadCount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppDecorations.brandGradient,
                              borderRadius: BorderRadius.circular(
                                AppDecorations.radiusFull,
                              ),
                            ),
                            child: Text(
                              '${conv.unreadCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                    onTap: () => context.push('/chat/${conv.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversationId});
  final String conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _service = MessagingService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) return;
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final parts = widget.conversationId.split('_');
    final recipientId =
        parts.firstWhere((p) => p != user.uid, orElse: () => parts.last);

    await _service.sendMessage(
      senderId: user.uid,
      recipientId: recipientId,
      text: _controller.text.trim(),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const NaseemAppBar(title: 'Chat'),
      body: PremiumBackground(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _service.watchMessages(widget.conversationId),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const PremiumLoading(message: 'Loading messages…');
                  }
                  final messages = snap.data!;
                  if (messages.isEmpty) {
                    return const PremiumEmptyState(
                      title: 'Start the conversation',
                      subtitle: 'Send a message to begin chatting',
                      icon: Icons.waving_hand_rounded,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final isMe = msg.senderId == user?.uid;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            gradient: isMe
                                ? AppDecorations.purplePinkGradient
                                : null,
                            color: isMe
                                ? null
                                : AppColors.navyCard.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.only(
                              topLeft:
                                  const Radius.circular(AppDecorations.radiusLg),
                              topRight:
                                  const Radius.circular(AppDecorations.radiusLg),
                              bottomLeft: Radius.circular(
                                  isMe ? AppDecorations.radiusLg : 4),
                              bottomRight: Radius.circular(
                                  isMe ? 4 : AppDecorations.radiusLg),
                            ),
                            border: isMe
                                ? null
                                : Border.all(color: AppColors.border),
                            boxShadow: isMe ? AppDecorations.purpleGlow : null,
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: isMe
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: AppDecorations.glass(opacity: 0.9),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Message…',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppDecorations.brandGradient,
                        borderRadius:
                            BorderRadius.circular(AppDecorations.radiusMd),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
