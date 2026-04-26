import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/forum_provider.dart';
import '../providers/localization_provider.dart';
import '../services/admin_service.dart';
import '../services/ai_service.dart';
import '../utils/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _postController = TextEditingController();
  final _aiQuestionController = TextEditingController();
  final _aiService = AiService();
  final _tts = FlutterTts();
  final _adminService = AdminService();
  bool _isAdmin = false;

  String? _aiAnswer;
  bool _askingAi = false;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final userId = auth.currentUser?.id ?? '';
      _adminService.isAdmin(userId).then((v) {
        if (mounted) setState(() => _isAdmin = v);
      });
      context.read<ForumProvider>().loadPosts();
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _postController.dispose();
    _aiQuestionController.dispose();
    super.dispose();
  }

  Future<void> _askAi() async {
    final q = _aiQuestionController.text.trim();
    if (q.isEmpty || _askingAi) return;

    setState(() {
      _askingAi = true;
      _aiAnswer = null;
      _speaking = false;
    });
    await _tts.stop();

    try {
      final ans = await _aiService.askCoconutAssistant(question: q);
      if (!mounted) return;
      setState(() => _aiAnswer = ans);
    } finally {
      if (mounted) setState(() => _askingAi = false);
    }
  }

  Future<void> _postToCommunity({
    required String content,
    String? aiAnswer,
  }) async {
    final auth = context.read<AuthProvider>();
    final forum = context.read<ForumProvider>();

    final userId = auth.currentUser?.id ?? 'temp_user_id';
    final userName = auth.currentUser?.name ?? 'Farmer';

    if (aiAnswer != null && aiAnswer.trim().isNotEmpty) {
      final post = await forum.createPostWithAiAnswer(
        userId: userId,
        userName: userName,
        question: content,
        aiAnswer: aiAnswer,
      );
      if (!mounted) return;
      if (post != null) {
        _aiQuestionController.clear();
        setState(() => _aiAnswer = null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Posted to community.')));
        context.push('/community/post/${post.id}');
      }
      return;
    }

    final post = await forum.createPost(
      userId: userId,
      userName: userName,
      content: content,
    );
    if (!mounted) return;
    if (post != null) {
      _postController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Posted.')));
      context.push('/community/post/${post.id}');
    }
  }

  Future<void> _toggleSpeak() async {
    final text = _aiAnswer?.trim() ?? '';
    if (text.isEmpty) return;

    if (_speaking) {
      await _tts.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }

    setState(() => _speaking = true);
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _speaking = false);
    });
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        final loc = context.read<LocalizationProvider>();
        return AlertDialog(
          title: Text(loc.translate('logout')),
          content: Text('Do you want to log out now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(loc.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(loc.translate('logout')),
            ),
          ],
        );
      },
    );
    if (shouldLogout != true) return;

    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FCED),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icon.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Cocolytics',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006527),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF006527),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TabBar(
                  indicatorPadding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    color: const Color(0xFF006527),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF006527),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loc.translate('get_ai_answer') ?? 'Get AI Answer',
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.auto_awesome, size: 16),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loc.translate('ask_community') ?? 'Ask Community',
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.people, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_buildAskAiTab(loc), _buildCommunityTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAskAiTab(LocalizationProvider loc) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        const Text(
          'Expert Advice,\nInstantly.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Color(0xFF006527),
            height: 1.1,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Connect with our AI specialized in coconut palm health and the global farming community.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            color: Color(0xFF5F6F68),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5E5),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TextField(
                  controller: _aiQuestionController,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    color: Color(0xFF171D14),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about coconut diseases...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      color: Color(0xFF8A9792),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 16, right: 12),
                      child: Icon(
                        Icons.psychology_outlined,
                        color: Color(0xFF006527),
                        size: 24,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _askingAi ? null : _askAi,
                  icon: _askingAi
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(''),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_askingAi)
                        Text(loc.translate('get_ai_answer') ?? 'Get AI Answer'),
                      if (!_askingAi) const SizedBox(width: 8),
                      if (!_askingAi) const Icon(Icons.auto_awesome, size: 18),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006527),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_aiAnswer != null) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5E5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF006527),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          loc.translate('ai_answer') ?? 'AI Answer',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF171D14),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        _speaking
                            ? Icons.stop_circle_outlined
                            : Icons.volume_up_outlined,
                        color: const Color(0xFF006527),
                      ),
                      onPressed: _toggleSpeak,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MarkdownBody(
                  data: _aiAnswer!,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      color: Color(0xFF3F4A3E),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _aiAnswer = null);
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(loc.translate('ask_again') ?? 'Ask Again'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF006527),
                          side: const BorderSide(color: Color(0xFF006527)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _postToCommunity(
                          content: _aiQuestionController.text.trim(),
                          aiAnswer: _aiAnswer,
                        ),
                        icon: const Icon(Icons.forum, size: 18),
                        label: Text(
                          loc.translate('ask_community') ?? 'Ask Community',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006527),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ],
    );
  }

  Widget _buildCommunityTab() {
    final forum = context.watch<ForumProvider>();
    final loc = context.watch<LocalizationProvider>();
    return RefreshIndicator(
      onRefresh: () => context.read<ForumProvider>().loadPosts(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5E5),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: TextField(
                    controller: _postController,
                    maxLines: 3,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      color: Color(0xFF171D14),
                    ),
                    decoration: InputDecoration(
                      hintText:
                          loc.translate('post_question') ??
                          'Ask the community about a disease, treatment, or farming issue...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFF8A9792),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: forum.isPosting
                        ? null
                        : () => _postToCommunity(
                            content: _postController.text.trim(),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006527),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: forum.isPosting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            loc.translate('post') ?? 'Post',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (forum.state == ForumState.loading)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF006527)),
              ),
            )
          else if (forum.state == ForumState.error)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                forum.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (forum.posts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  loc.translate('no_posts_yet') ?? 'No posts yet',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF8A9792),
                  ),
                ),
              ),
            )
          else
            ...forum.posts.map(
              (p) => _PostCard(postId: p.id, isAdmin: _isAdmin),
            ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String postId;
  final bool isAdmin;
  const _PostCard({required this.postId, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final forum = context.watch<ForumProvider>();
    final post = forum.posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => throw StateError('Post not found'),
    );

    final aiReply = post.replies.where((r) => r.isAiReply).toList();
    final latestAi = aiReply.isNotEmpty ? aiReply.last : null;

    return InkWell(
      onTap: () => context.push('/community/post/${post.id}'),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFEAF5E5),
                  child: const Icon(Icons.person, color: Color(0xFF006527)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF171D14),
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _timeAgo(post.timestamp),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          color: Color(0xFF8A9792),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  IconButton(
                    tooltip: 'Delete post',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
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
                      if (!context.mounted) return;
                      await context.read<ForumProvider>().deletePost(post.id);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Post deleted.')),
                      );
                    },
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5FCED),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${post.replies.where((r) => !r.isAiReply).length} replies',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006527),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.content,
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF3F4A3E),
                height: 1.5,
                fontSize: 15,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (latestAi != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FCED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF006527).withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF006527),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI: ${latestAi.content}',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: Color(0xFF5F6F68),
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: Color(0xFF8A9792),
                ),
                SizedBox(width: 6),
                Text(
                  'Tap to view & reply',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: Color(0xFF8A9792),
                  ),
                ),
              ],
            ),
          ],
        ),
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
