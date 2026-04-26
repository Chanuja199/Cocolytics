import 'package:flutter/material.dart';
import '../models/forum_post_model.dart';
import '../services/forum_service.dart';

enum ForumState { idle, loading, success, error }

class ForumProvider extends ChangeNotifier {
  final ForumService _forumService = ForumService();

  ForumState _state = ForumState.idle;
  List<ForumPostModel> _posts = [];
  String _errorMessage = '';
  bool _isPosting = false;

  ForumState get state => _state;
  List<ForumPostModel> get posts => _posts;
  String get errorMessage => _errorMessage;
  bool get isPosting => _isPosting;

  Future<void> loadPosts() async {
    _state = ForumState.loading;
    notifyListeners();

    try {
      _posts = await _forumService.getPostsFeed();
      _state = ForumState.success;
    } catch (e) {
      _errorMessage = 'Could not load posts: ${e.toString()}';
      _state = ForumState.error;
    }

    notifyListeners();
  }

  Future<ForumPostModel?> createPost({
    required String userId,
    required String userName,
    required String content,
    String? imageUrl,
  }) async {
    _isPosting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final post = await _forumService.createPost(
        userId: userId,
        userName: userName,
        content: content,
        imageUrl: imageUrl,
      );

      // Add to top of list
      _posts.insert(0, post);

      // Trigger AI auto-reply in background
      _forumService.generateAiReply(postId: post.id, content: content).then((
        updatedPost,
      ) {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
      });
    } catch (e) {
      _errorMessage = 'Could not create post: ${e.toString()}';
      return null;
    } finally {
      _isPosting = false;
      notifyListeners();
    }
    return _posts.isNotEmpty ? _posts.first : null;
  }

  Future<ForumPostModel?> createPostWithAiAnswer({
    required String userId,
    required String userName,
    required String question,
    required String aiAnswer,
    String? imageUrl,
  }) async {
    final post = await createPost(
      userId: userId,
      userName: userName,
      content: question,
      imageUrl: imageUrl,
    );
    if (post == null) return null;

    try {
      final updated = await _forumService.addAiReply(
        postId: post.id,
        content: aiAnswer,
      );
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = updated;
        notifyListeners();
      }
      return updated;
    } catch (e) {
      return post;
    }
  }

  Future<void> addReply({
    required String postId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    try {
      final updatedPost = await _forumService.addReply(
        postId: postId,
        userId: userId,
        userName: userName,
        content: content,
      );

      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Could not add reply: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _forumService.deletePost(postId: postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Could not delete post: ${e.toString()}';
      notifyListeners();
    }
  }
}
