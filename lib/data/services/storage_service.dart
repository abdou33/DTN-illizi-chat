import 'dart:io';

class StorageService {
  // Simulates uploading a profile image by returning the local file path
  Future<String> uploadProfileImage(File file) async {
    // Just return the local path of the file so it can be rendered locally
    return file.path;
  }

  // Simulates uploading media by returning the local file path
  Future<String> uploadChatMedia({
    required File file,
    required String chatId,
    required String mediaType,
    String? fileName,
  }) async {
    return file.path;
  }

  // Simulates uploading a voice message
  Future<String> uploadVoiceMessage({
    required File file,
    required String chatId,
  }) async {
    return file.path;
  }
}
