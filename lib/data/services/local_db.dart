import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class LocalDb extends ChangeNotifier {
  static final LocalDb _instance = LocalDb._();
  factory LocalDb() => _instance;
  LocalDb._();

  static const _uuid = Uuid();

  UserModel? currentUser;
  List<UserModel> users = [];
  List<ChatModel> _allChats = [];
  final Map<String, List<MessageModel>> _messagesByChat = {};
  final Map<String, String> _passwordsByPhone = {};

  bool _initialized = false;

  List<ChatModel> get chats {
    if (currentUser == null) return [];
    return _allChats
        .where((c) => c.participants.contains(currentUser!.uid))
        .toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _load();
  }

  Future<UserModel> signUp({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    final phone = phoneNumber.trim();
    if (_passwordsByPhone.containsKey(phone)) {
      throw Exception('An account with this phone number already exists');
    }

    final user = UserModel(
      uid: _uuid.v4(),
      name: name.trim(),
      phoneNumber: phone,
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
    );

    users.add(user);
    _passwordsByPhone[phone] = password;
    currentUser = user;
    notifyListeners();
    await _save();
    return user;
  }

  Future<UserModel> logIn({
    required String phoneNumber,
    required String password,
  }) async {
    final phone = phoneNumber.trim();
    final stored = _passwordsByPhone[phone];
    if (stored == null || stored != password) {
      throw Exception('Invalid phone number or password');
    }

    final user = users.firstWhere(
      (u) => u.phoneNumber == phone,
      orElse: () => throw Exception('Invalid phone number or password'),
    );

    currentUser = user.copyWith(isOnline: true, lastSeen: DateTime.now());
    _updateUserInList(currentUser!);
    notifyListeners();
    await _save();
    return currentUser!;
  }

  Future<void> updateProfile({
    String? name,
    String? about,
    String? profileImageUrl,
  }) async {
    if (currentUser == null) return;
    currentUser = currentUser!.copyWith(
      name: name,
      about: about,
      profileImageUrl: profileImageUrl,
    );
    _updateUserInList(currentUser!);
    notifyListeners();
    await _save();
  }

  List<UserModel> searchUsers(String query) {
    final q = query.toLowerCase();
    return users.where((u) {
      if (u.uid == currentUser?.uid) return false;
      return u.name.toLowerCase().contains(q) || u.phoneNumber.contains(query);
    }).toList();
  }

  Future<String> getOrCreateChat(String otherUserId) async {
    final myId = currentUser?.uid;
    if (myId == null) throw Exception('Not logged in');

    final existing = _allChats.where((c) {
      return c.participants.length == 2 &&
          c.participants.contains(myId) &&
          c.participants.contains(otherUserId);
    }).firstOrNull;

    if (existing != null) return existing.chatId;

    final chat = ChatModel(
      chatId: _uuid.v4(),
      participants: [myId, otherUserId],
      lastMessage: '',
      lastMessageType: 'text',
      lastMessageSenderId: '',
      lastMessageTime: DateTime.now(),
    );
    _allChats.add(chat);
    _messagesByChat[chat.chatId] = [];
    notifyListeners();
    await _save();
    return chat.chatId;
  }

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
    required MessageType type,
    String? fileName,
    String? fileUrl,
    int? fileSizeBytes,
    int? audioDurationMs,
  }) async {
    final senderId = currentUser?.uid;
    if (senderId == null) return;

    final message = MessageModel(
      messageId: _uuid.v4(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
      fileName: fileName,
      fileUrl: fileUrl,
      fileSizeBytes: fileSizeBytes,
      timestamp: DateTime.now(),
      audioDurationMs: audioDurationMs,
    );

    _messagesByChat.putIfAbsent(chatId, () => []).add(message);

    final chatIndex = _allChats.indexWhere((c) => c.chatId == chatId);
    if (chatIndex >= 0) {
      final preview = _previewForMessage(message);
      _allChats[chatIndex] = ChatModel(
        chatId: chatId,
        participants: _allChats[chatIndex].participants,
        lastMessage: preview,
        lastMessageType: type.name,
        lastMessageSenderId: senderId,
        lastMessageTime: message.timestamp,
        unreadCount: _allChats[chatIndex].unreadCount,
      );
    }

    notifyListeners();
    await _save();
  }

  List<MessageModel> getMessagesForChat(String chatId) {
    final list = _messagesByChat[chatId] ?? [];
    return List<MessageModel>.from(list)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<UserModel?> getOtherUser(ChatModel chat) async {
    final myId = currentUser?.uid;
    if (myId == null) return null;
    final otherId = chat.participants.firstWhere((id) => id != myId, orElse: () => '');
    if (otherId.isEmpty) return null;
    try {
      return users.firstWhere((u) => u.uid == otherId);
    } catch (_) {
      return null;
    }
  }

  void markMessagesAsRead(String chatId) {
    final myId = currentUser?.uid;
    if (myId == null) return;

    final messages = _messagesByChat[chatId];
    if (messages == null) return;

    var changed = false;
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].receiverId == myId && !messages[i].isRead) {
        messages[i] = MessageModel(
          messageId: messages[i].messageId,
          senderId: messages[i].senderId,
          receiverId: messages[i].receiverId,
          content: messages[i].content,
          type: messages[i].type,
          fileName: messages[i].fileName,
          fileUrl: messages[i].fileUrl,
          fileSizeBytes: messages[i].fileSizeBytes,
          timestamp: messages[i].timestamp,
          isRead: true,
          audioDurationMs: messages[i].audioDurationMs,
        );
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
      _save();
    }
  }

  int getUnreadCount(String chatId) {
    final myId = currentUser?.uid;
    if (myId == null) return 0;
    return (_messagesByChat[chatId] ?? [])
        .where((m) => m.receiverId == myId && !m.isRead)
        .length;
  }

  void _updateUserInList(UserModel user) {
    final i = users.indexWhere((u) => u.uid == user.uid);
    if (i >= 0) {
      users[i] = user;
    }
  }

  String _previewForMessage(MessageModel message) {
    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return 'Photo';
      case MessageType.video:
        return 'Video';
      case MessageType.audio:
        return 'Voice message';
      case MessageType.document:
        return message.fileName ?? 'Document';
    }
  }

  Future<File> _dbFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/dtn_chat_local_db.json');
  }

  Future<void> _save() async {
    try {
      final data = {
        'currentUserId': currentUser?.uid,
        'users': users.map((u) => u.toMap()).toList(),
        'passwords': _passwordsByPhone,
        'chats': _allChats.map((c) => c.toMap()).toList(),
        'messages': _messagesByChat.map(
          (chatId, msgs) => MapEntry(chatId, msgs.map((m) => _messageToJson(m)).toList()),
        ),
      };
      await (await _dbFile()).writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  Future<void> _load() async {
    try {
      final file = await _dbFile();
      if (!await file.exists()) return;

      final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      users = (data['users'] as List<dynamic>? ?? [])
          .map((e) => UserModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      _passwordsByPhone.clear();
      (data['passwords'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
        _passwordsByPhone[k] = v.toString();
      });
      _allChats = (data['chats'] as List<dynamic>? ?? [])
          .map((e) => ChatModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      _messagesByChat.clear();
      (data['messages'] as Map<String, dynamic>? ?? {}).forEach((chatId, list) {
        _messagesByChat[chatId] = (list as List<dynamic>)
            .map((e) => MessageModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      });

      final currentId = data['currentUserId'] as String?;
      if (currentId != null) {
        try {
          currentUser = users.firstWhere((u) => u.uid == currentId);
        } catch (_) {
          currentUser = null;
        }
      }
    } catch (_) {}
  }

  Map<String, dynamic> _messageToJson(MessageModel m) {
    return {
      'messageId': m.messageId,
      'senderId': m.senderId,
      'receiverId': m.receiverId,
      'content': m.content,
      'type': m.type.name,
      'fileName': m.fileName,
      'fileUrl': m.fileUrl,
      'fileSizeBytes': m.fileSizeBytes,
      'timestamp': m.timestamp.toIso8601String(),
      'isRead': m.isRead,
      'audioDurationMs': m.audioDurationMs,
    };
  }
}
