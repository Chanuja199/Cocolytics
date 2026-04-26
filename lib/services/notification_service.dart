import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.map((d) => d.data()).toList();
  }

  Future<void> createUserNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
    String? postId,
    String? actorUserId,
  }) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc();
    await ref.set({
      'id': ref.id,
      'title': title,
      'body': body,
      'type': type ?? 'general',
      'postId': postId,
      'actorUserId': actorUserId,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    });
  }

  Future<void> markAllRead(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }
}

