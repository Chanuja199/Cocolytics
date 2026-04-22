class ForumReply {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final bool isAiReply;
  final DateTime timestamp;

  ForumReply({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.isAiReply,
    required this.timestamp,
  });

  factory ForumReply.fromMap(Map<String, dynamic> map) => ForumReply(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? '',
    content: map['content'] ?? '',
    isAiReply: map['isAiReply'] ?? false,
    timestamp: DateTime.parse(map['timestamp']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'content': content,
    'isAiReply': isAiReply,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ForumPostModel {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String? imageUrl;
  final List<ForumReply> replies;
  final int likes;
  final String moderationStatus; // pending | approved | rejected
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime timestamp;

  ForumPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.imageUrl,
    required this.replies,
    required this.likes,
    required this.moderationStatus,
    this.approvedBy,
    this.approvedAt,
    required this.timestamp,
  });

  factory ForumPostModel.fromMap(Map<String, dynamic> map) => ForumPostModel(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? '',
    content: map['content'] ?? '',
    imageUrl: map['imageUrl'],
    replies: (map['replies'] as List? ?? [])
        .map((e) => ForumReply.fromMap(e))
        .toList(),
    likes: map['likes'] ?? 0,
    moderationStatus: map['moderationStatus'] ?? 'approved',
    approvedBy: map['approvedBy'],
    approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
    timestamp: DateTime.parse(map['timestamp']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'content': content,
    'imageUrl': imageUrl,
    'replies': replies.map((e) => e.toMap()).toList(),
    'likes': likes,
    'moderationStatus': moderationStatus,
    'approvedBy': approvedBy,
    'approvedAt': approvedAt?.toIso8601String(),
    'timestamp': timestamp.toIso8601String(),
  };
}
