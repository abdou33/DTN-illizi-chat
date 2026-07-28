import 'package:dtn_chat/data/models/user_model.dart';

class ChatModel {
  final String chatId;
  final List<UserModel> participants;
  final String lastMessage;
  final String lastMessageType;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    final lastMessage = map['last_message'];
    return ChatModel(
      chatId: "${map['id']}" ?? '',
      participants: (map['users'] as List)
          .map((e) => UserModel.fromMap(e))
          .toList(),
      lastMessage: lastMessage?['message'] ?? '',
      lastMessageType: lastMessage?['type'] ?? 'text',
      lastMessageTime: lastMessage?['created_at'] != null
          ? DateTime.parse(lastMessage['created_at'])
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
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}
