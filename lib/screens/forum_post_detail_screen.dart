import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forum_post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/forum_provider.dart';
import '../services/forum_service.dart';
import '../services/admin_service.dart';
import '../utils/app_colors.dart';

class ForumPostDetailScreen extends StatefulWidget {
  final String postId;
  const ForumPostDetailScreen({super.key, required this.postId});

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  final _replyController = TextEditingController();
  final _service = ForumService();
  final _adminService = AdminService();
  bool _sending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _sending) return;

    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? 'temp_user_id';
    final userName = auth.currentUser?.name ?? 'Farmer';

    setState(() => _sending = true);
    try {
      await context.read<ForumProvider>().addReply(
        postId: widget.postId,
        userId: userId,
        userName: userName,
        content: text,
      );
      _replyController.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Community',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          FutureBuilder<bool>(
            future: _adminService.isAdmin(userId),
            builder: (context, snap) {
              final isAdmin = snap.data == true;
              if (!isAdmin) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Delete post',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete post?'),
                      content: const Text(
                        'This will permanently delete the post from the community.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (shouldDelete != true) return;

                  await _service.deletePost(postId: widget.postId);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<ForumPostModel?>(
        stream: _service.watchPost(widget.postId),
        builder: (context, snapshot) {
          final post = snapshot.data;
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _PostHeader(post: post),
                    const SizedBox(height: 12),
                    _PostBody(post: post),
                    const SizedBox(height: 16),
                    const Text(
                      'Replies',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (post.replies.isEmpty)
                      const Text(
                        'No replies yet. Be the first to reply.',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      ...post.replies
                          .toList()
                          .reversed
                          .map((r) => _ReplyTile(reply: r)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Write a reply…',
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _sending ? null : _sendReply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _sending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final ForumPostModel post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primaryLight.withAlpha(64),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _timeAgo(post.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PostBody extends StatelessWidget {
  final ForumPostModel post;
  const _PostBody({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        post.content,
        style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  final ForumReply reply;
  const _ReplyTile({required this.reply});

  @override
  Widget build(BuildContext context) {
    final isAi = reply.isAiReply;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAi ? AppColors.background : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isAi
            ? Border.all(color: AppColors.primary.withAlpha(64))
            : Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isAi ? Icons.smart_toy : Icons.person,
            size: 18,
            color: isAi ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAi ? AppColors.primary : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(reply.timestamp),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  reply.content,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    height: 1.35,
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

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

