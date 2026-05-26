import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/local_db.dart';
import '../../../data/services/storage_service.dart';
import '../helpers/voice_recorder_helper.dart';
import '../widgets/attachment_sheet.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';

class ConversationScreen extends StatefulWidget {
  final UserModel otherUser;
  final String chatId;

  const ConversationScreen({super.key, required this.otherUser, required this.chatId});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _chat = ChatService();
  final _storage = StorageService();
  final _voice = VoiceRecorderHelper();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();

  late final String _myId;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _myId = AuthService().currentUser?.uid ?? '';
    _chat.markMessagesAsRead(widget.chatId);
    _voice.init(() => setState(() {}));
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _voice.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    _refresh();
    await _chat.sendMessage(
      chatId: widget.chatId,
      receiverId: widget.otherUser.uid,
      content: text,
      type: MessageType.text,
    );
    _scrollToBottom();
  }

  Future<void> _sendFile({
    required File file,
    required MessageType type,
    String? fileName,
    int? fileSizeBytes,
    int? audioDurationMs,
  }) async {
    setState(() => _sending = true);
    try {
      final path = type == MessageType.audio
          ? await _storage.uploadVoiceMessage(file: file, chatId: widget.chatId)
          : await _storage.uploadChatMedia(
              file: file,
              chatId: widget.chatId,
              mediaType: type.name,
              fileName: fileName,
            );
      await _chat.sendMessage(
        chatId: widget.chatId,
        receiverId: widget.otherUser.uid,
        content: path,
        type: type,
        fileUrl: path,
        fileName: fileName,
        fileSizeBytes: fileSizeBytes,
        audioDurationMs: audioDurationMs,
      );
      _scrollToBottom();
    } catch (_) {
      if (mounted) showAppSnackBar(context, 'Failed to send message', isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 70);
    if (file == null) return;
    await _sendFile(file: File(file.path), type: MessageType.image, fileName: file.name);
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    await _sendFile(file: File(file.path), type: MessageType.video, fileName: file.name);
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt', 'csv', 'zip'],
    );
    if (result == null || result.files.isEmpty || result.files.first.path == null) return;
    final f = result.files.first;
    await _sendFile(
      file: File(f.path!),
      type: MessageType.document,
      fileName: f.name,
      fileSizeBytes: f.size,
    );
  }

  Future<void> _toggleVoice() async {
    if (_voice.isRecording) {
      final result = await _voice.stop(context);
      if (result == null) return;
      await _sendFile(
        file: File(result.path),
        type: MessageType.audio,
        fileName: 'Voice message',
        audioDurationMs: result.durationMs,
      );
    } else {
      await _voice.start(context, _refresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.otherUser;

    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      appBar: AppBar(
        backgroundColor: AppColors.iosSecondaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leadingWidth: 30,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.darkGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            UserAvatar(user: user, radius: 18, heroTag: 'avatar_${user.uid}'),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(
                  user.isOnline ? 'online' : 'last seen ${DateFormat.Hm().format(user.lastSeen)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: user.isOnline ? AppColors.online : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: LocalDb(),
              builder: (_, __) {
                final messages = LocalDb().getMessagesForChat(widget.chatId);
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nSay hello! 👋',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => MessageBubble(
                    message: messages[i],
                    isMe: messages[i].senderId == _myId,
                    playingMessageId: _voice.playingMessageId,
                    onPlayAudio: (url, id) => _voice.togglePlayback(url, id, _refresh),
                  ),
                );
              },
            ),
          ),
          if (_voice.isRecording)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.error.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _voice.recordingLabel,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error),
                  ),
                  const Spacer(),
                  const Text('Tap stop to send', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen)),
                  SizedBox(width: 8),
                  Text('Sending...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ChatInputBar(
            controller: _msgCtrl,
            isRecording: _voice.isRecording,
            onAttach: () => showAttachmentSheet(
              context,
              onGallery: () => _pickImage(ImageSource.gallery),
              onCamera: () => _pickImage(ImageSource.camera),
              onVideo: _pickVideo,
              onDocument: _pickDocument,
            ),
            onSend: _sendText,
            onToggleRecord: _toggleVoice,
            onTextChanged: _refresh,
          ),
        ],
      ),
    );
  }
}
