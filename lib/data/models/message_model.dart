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
  final String content;
  final MessageType type;
  final String? fileUrl;
  // for ui affichage
  final int? fileSizeBytes;
  final DateTime timestamp;
  final bool isRead;
  final int? audioDurationMs;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.type,
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
      messageId: "${map['id']}" ?? '',
      senderId: "${map['sender_id']}" ?? '',
      content: map['message'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      fileUrl: map['attachment'],
      fileSizeBytes: map['file_size'],
      timestamp: timestamp,
      isRead: map['is_read'] == 1,
      audioDurationMs: map['audioDurationMs'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'fileUrl': fileUrl,
      'fileSizeBytes': fileSizeBytes,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'audioDurationMs': audioDurationMs,
    };
  }
}
