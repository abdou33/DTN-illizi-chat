import 'dart:io';

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
    File? file,
    int? audioDurationMs,
  }) async {
    final formData = FormData.fromMap({
      'conversation_id': chatId,
      'type': type.name,
      'message': content,
      'reply_to_id': null,
    });

    if (file != null) {
      formData.files.add(
        MapEntry(
          'attachment',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }

    final response = await dio.post(
      "${AppUrls.api_url}/api/messages",
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        contentType: 'multipart/form-data',
        validateStatus: (status) => true,
      ),
    );

    if (response.statusCode == 201) {
      return MessageModel.fromMap(response.data);
    }

    throw Exception(
      response.data is Map
          ? response.data['error']?.toString() ??
                response.data['message']?.toString() ??
                'Sending file failed'
          : 'Sending file failed with status code ${response.statusCode}',
    );
  }
}
