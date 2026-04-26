import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/forum_post_model.dart';
import 'ai_service.dart';
import 'notification_service.dart';

class ForumService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  final AiService _ai = AiService();
  final NotificationService _notificationService = NotificationService();

  Future<List<ForumPostModel>> getPostsFeed() async {
    final snapshot = await _db
        .collection('forum_posts')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.map((d) => ForumPostModel.fromMap(d.data())).toList();
  }

  Future<ForumPostModel> createPost({
    required String userId,
    required String userName,
    required String content,
    String? imageUrl,
  }) async {
    final id = _uuid.v4();
    final post = ForumPostModel(
      id: id,
      userId: userId,
      userName: userName,
      content: content,
      imageUrl: imageUrl,
      replies: [],
      likes: 0,
      moderationStatus: 'approved',
      approvedBy: null,
      approvedAt: null,
      timestamp: DateTime.now(),
    );

    await _db.collection('forum_posts').doc(id).set(post.toMap());
    return post;
  }

  Stream<ForumPostModel?> watchPost(String postId) {
    return _db.collection('forum_posts').doc(postId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return ForumPostModel.fromMap(data);
    });
  }

  // Generates an AI reply (free-tier: Gemini) and saves it.
  Future<ForumPostModel> generateAiReply({
    required String postId,
    required String content,
  }) async {
    try {
      final aiReplyText = await _ai.draftForumReply(question: content);

      // Save AI reply to Firestore
      final replyId = _uuid.v4();
      final aiReply = ForumReply(
        id: replyId,
        userId: 'ai_assistant',
        userName: 'GreenScan AI',
        content: aiReplyText,
        isAiReply: true,
        timestamp: DateTime.now(),
      );

      await _db.collection('forum_posts').doc(postId).update({
        'replies': FieldValue.arrayUnion([aiReply.toMap()]),
      });

      // Return updated post
      final doc = await _db.collection('forum_posts').doc(postId).get();
      return ForumPostModel.fromMap(doc.data()!);
    } catch (e) {
      // If AI fails, still return the post without AI reply
      final doc = await _db.collection('forum_posts').doc(postId).get();
      return ForumPostModel.fromMap(doc.data()!);
    }
  }

  Future<ForumPostModel> addAiReply({
    required String postId,
    required String content,
  }) async {
    final replyId = _uuid.v4();
    final aiReply = ForumReply(
      id: replyId,
      userId: 'ai_assistant',
      userName: 'GreenScan AI',
      content: content,
      isAiReply: true,
      timestamp: DateTime.now(),
    );

    await _db.collection('forum_posts').doc(postId).update({
      'replies': FieldValue.arrayUnion([aiReply.toMap()]),
    });

    final doc = await _db.collection('forum_posts').doc(postId).get();
    return ForumPostModel.fromMap(doc.data()!);
  }

  Future<ForumPostModel> addReply({
    required String postId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    final postDoc = await _db.collection('forum_posts').doc(postId).get();
    final post = ForumPostModel.fromMap(postDoc.data()!);

    final reply = ForumReply(
      id: _uuid.v4(),
      userId: userId,
      userName: userName,
      content: content,
      isAiReply: false,
      timestamp: DateTime.now(),
    );

    await _db.collection('forum_posts').doc(postId).update({
      'replies': FieldValue.arrayUnion([reply.toMap()]),
    });

    if (post.userId != userId) {
      await _notificationService.createUserNotification(
        userId: post.userId,
        title: 'New comment on your post',
        body: '$userName replied: ${content.trim()}',
        type: 'post_comment',
        postId: postId,
        actorUserId: userId,
      );
    }

    final doc = await _db.collection('forum_posts').doc(postId).get();
    return ForumPostModel.fromMap(doc.data()!);
  }

  Future<List<ForumPostModel>> getPendingPostsForAdmin() async => [];
  Future<void> approvePost({
    required String postId,
    required String adminUserId,
  }) async {}

  Future<void> deletePost({required String postId}) async {
    await _db.collection('forum_posts').doc(postId).delete();
  }
}
