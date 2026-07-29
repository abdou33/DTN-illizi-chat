import 'package:dio/dio.dart';
import 'package:dtn_chat/core/constants/app_urls.dart';
import 'package:dtn_chat/data/services/auth_service.dart';

import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'local_db.dart';

class ChatService {
  final dio = Dio();
  Future<MessageModel?> sendMessage({
    required String chatId,
    required String content,
    required MessageType type,
    String? fileUrl,
    int? fileSizeBytes,
    int? audioDurationMs,
  }) async {
    final response = await dio.post(
      "${AppUrls.api_url}/api/messages",
      data: {
        'conversation_id': chatId,
        'type': type.name,
        'message': content,
        'attachment': fileUrl,
        'reply_to_id': null,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        validateStatus: (status) => true, // accept all codes
      ),
    );

    if (response.statusCode == 201) {
      MessageModel chat = MessageModel.fromMap(response.data);
      return chat;
    } else {
      throw Exception(
        response.data['error']?.toString() ??
            'sending message failed with status code ${response.statusCode}',
      );
    }
  }
}
