import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../core/theme/app_colors.dart';
import '../models/social_models.dart';
import '../providers/auth_provider.dart';
import '../providers/comment_provider.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    super.key,
    required this.videoId,
    this.videoOwnerId,
  });

  final String videoId;
  final String? videoOwnerId;

  static Future<void> show(
    BuildContext context, {
    required String videoId,
    String? videoOwnerId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(videoId: videoId, videoOwnerId: videoOwnerId),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _controller = TextEditingController();
  String? _replyToId;
  String? _replyToName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().watchComments(widget.videoId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    await context.read<CommentProvider>().addComment(
          videoId: widget.videoId,
          userId: user.uid,
          userDisplayName: user.displayName,
          userPhotoUrl: user.photoUrl,
          text: _controller.text.trim(),
          parentCommentId: _replyToId,
          videoOwnerId: widget.videoOwnerId,
        );

    _controller.clear();
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comments = context.watch<CommentProvider>().comments;
    final user = context.watch<AuthProvider>().user;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${comments.length} Comments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: comments.isEmpty
                    ? const Center(child: Text('Be the first to comment'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: comments.length,
                        itemBuilder: (_, i) => _CommentTile(
                          comment: comments[i],
                          currentUserId: user?.uid,
                          onReply: () => setState(() {
                            _replyToId = comments[i].id;
                            _replyToName = comments[i].userDisplayName;
                          }),
                        ),
                      ),
              ),
              if (_replyToName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('Replying to $_replyToName',
                          style: TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() {
                          _replyToId = null;
                          _replyToName = null;
                        }),
                      ),
                    ],
                  ),
                ),
              _CommentInput(
                controller: _controller,
                onSubmit: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    this.currentUserId,
    required this.onReply,
  });

  final CommentModel comment;
  final String? currentUserId;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryGreen,
        backgroundImage: comment.userPhotoUrl != null
            ? NetworkImage(comment.userPhotoUrl!)
            : null,
        child: comment.userPhotoUrl == null
            ? Text(comment.userDisplayName[0].toUpperCase())
            : null,
      ),
      title: Row(
        children: [
          Text(comment.userDisplayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          if (comment.createdAt != null) ...[
            const SizedBox(width: 8),
            Text(timeago.format(comment.createdAt!), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.text),
          Row(
            children: [
              Text('${comment.likeCount} likes', style: const TextStyle(fontSize: 11)),
              TextButton(onPressed: onReply, child: const Text('Reply', style: TextStyle(fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({required this.controller, required this.onSubmit});
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primaryGreen),
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
