enum MessageType {
  text,
  image,
  video,
  audio,
  document,
}

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final String? fileName;
  final String? fileUrl;
  final int? fileSizeBytes;
  final DateTime timestamp;
  final bool isRead;
  final int? audioDurationMs;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    this.fileName,
    this.fileUrl,
    this.fileSizeBytes,
    required this.timestamp,
    this.isRead = false,
    this.audioDurationMs,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    DateTime timestamp = DateTime.now();
    final raw = map['timestamp'];
    if (raw is String) {
      timestamp = DateTime.tryParse(raw) ?? DateTime.now();
    } else if (raw is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(raw);
    }

    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      fileName: map['fileName'],
      fileUrl: map['fileUrl'],
      fileSizeBytes: map['fileSizeBytes'],
      timestamp: timestamp,
      isRead: map['isRead'] ?? false,
      audioDurationMs: map['audioDurationMs'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.name,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSizeBytes': fileSizeBytes,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'audioDurationMs': audioDurationMs,
    };
  }
}
