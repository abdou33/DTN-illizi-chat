class ChatModel {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageType;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageType: map['lastMessageType'] ?? 'text',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : DateTime.now(),
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}
