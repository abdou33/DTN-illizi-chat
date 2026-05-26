import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'local_db.dart';

/// Thin API over [LocalDb] for chat operations.
class ChatService {
  final LocalDb _db = LocalDb();

  Future<String> getOrCreateChat(String otherUserId) => _db.getOrCreateChat(otherUserId);

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
    required MessageType type,
    String? fileName,
    String? fileUrl,
    int? fileSizeBytes,
    int? audioDurationMs,
  }) =>
      _db.sendMessage(
        chatId: chatId,
        receiverId: receiverId,
        content: content,
        type: type,
        fileName: fileName,
        fileUrl: fileUrl,
        fileSizeBytes: fileSizeBytes,
        audioDurationMs: audioDurationMs,
      );

  Future<UserModel?> getOtherUser(ChatModel chat) => _db.getOtherUser(chat);

  void markMessagesAsRead(String chatId) => _db.markMessagesAsRead(chatId);
}
