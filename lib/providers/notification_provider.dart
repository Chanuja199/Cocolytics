import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  int _unreadCount = 0;
  final List<Map<String, dynamic>> _notifications = [];

  int get unreadCount => _unreadCount;
  List<Map<String, dynamic>> get notifications => _notifications;

  void addNotification(String title, String body) {
    _notifications.insert(0, {
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    });
    _unreadCount++;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _notifications) {
      n['isRead'] = true;
    }
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> loadNotifications(String userId) async {
    if (userId.trim().isEmpty || userId == 'temp_user_id') {
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
      return;
    }
    final list = await _service.getUserNotifications(userId);
    _notifications
      ..clear()
      ..addAll(list);
    _unreadCount = _notifications.where((n) => n['isRead'] != true).length;
    notifyListeners();
  }

  Future<void> addNotificationForUser({
    required String userId,
    required String title,
    required String body,
    String? type,
    String? postId,
    String? actorUserId,
  }) async {
    addNotification(title, body);
    if (userId.trim().isEmpty || userId == 'temp_user_id') return;
    await _service.createUserNotification(
      userId: userId,
      title: title,
      body: body,
      type: type,
      postId: postId,
      actorUserId: actorUserId,
    );
    await loadNotifications(userId);
  }

  Future<void> markAllReadForUser(String userId) async {
    markAllRead();
    if (userId.trim().isEmpty || userId == 'temp_user_id') return;
    await _service.markAllRead(userId);
    await loadNotifications(userId);
  }
}
