import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dtn_chat/core/constants/app_urls.dart';
import 'package:dtn_chat/data/services/reverb_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/storage_service.dart';
import '../helpers/voice_recorder_helper.dart';
import '../widgets/attachment_sheet.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';

class ConversationScreen extends StatefulWidget {
  final UserModel otherUser;
  final String chatId;

  const ConversationScreen({
    super.key,
    required this.otherUser,
    required this.chatId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _chat = ChatService();
  final _voice = VoiceRecorderHelper();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();
  late final Channel _conversationChannel;
  final dio = Dio();
  var logger = Logger();

  late final String _myId;
  bool _sending = false;
  bool _loading = false;

  // msg pagination
  bool _hasMoreMessages = true;
  bool _loadingMoreMessages = false;
  String? _beforeMessageId;

  List<MessageModel> messages = [];

  @override
  void initState() {
    super.initState();
    getMessagesForChat();
    _myId = AuthService.currentUser?.id ?? '';
    // _chat.markMessagesAsRead(widget.chatId);
    _voice.init(() => setState(() {}));
    _listenToConversation();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _voice.dispose();
    ReverbService.client.unsubscribeFromChannel(
      'private-conversation.${widget.chatId}',
    );
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;

    if (_scrollCtrl.position.pixels <= 100 &&
        _hasMoreMessages &&
        !_loadingMoreMessages) {
      getMessagesForChat();
    }
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
    setState(() => _sending = true);

    try {
      MessageModel? msg = await _chat.sendMessage(
        chatId: widget.chatId,
        content: text,
        type: MessageType.text,
      );
      // logger.i("msg content ${msg?.content}");
    } catch (e) {
      // logger.e(e);
      if (mounted)
        showAppSnackBar(context, cleanErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    _msgCtrl.clear();
    _refresh();
    _scrollToBottom();
  }

  Future<void> _sendFile({
    required File file,
    required MessageType type,
    required String fileName,
    int? fileSizeBytes,
    int? audioDurationMs,
  }) async {
    setState(() => _sending = true);

    try {
      final MessageModel? msg = await _chat.sendMessage(
        chatId: widget.chatId,
        content: fileName,
        type: type,
        file: file,
        audioDurationMs: audioDurationMs,
      );

      // logger.i("file sent: ${msg?.content}");
    } catch (e) {
      logger.e(e);

      if (mounted) {
        showAppSnackBar(context, cleanErrorMessage(e), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }

    _refresh();
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 70);
    if (file == null) return;
    await _sendFile(
      file: File(file.path),
      type: MessageType.image,
      fileName: file.name,
    );
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    await _sendFile(
      file: File(file.path),
      type: MessageType.video,
      fileName: file.name,
    );
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'txt',
        'csv',
        'zip',
      ],
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.first.path == null)
      return;
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

  Future<void> _cancelVoice() async {
    if (!_voice.isRecording) return;

    await _voice.cancel();
    _refresh();
  }

  Future<void> getMessagesForChat() async {
    if (_loadingMoreMessages || !_hasMoreMessages) return;

    final isInitialLoad = _beforeMessageId == null;

    if (isInitialLoad) {
      if (mounted) {
        setState(() => _loading = true);
      }
    } else {
      if (mounted) {
        setState(() => _loadingMoreMessages = true);
      }
    }

    // Save position before adding older messages
    final oldScrollPosition = _scrollCtrl.hasClients
        ? _scrollCtrl.position.pixels
        : 0.0;

    final oldScrollExtent = _scrollCtrl.hasClients
        ? _scrollCtrl.position.maxScrollExtent
        : 0.0;

    try {
      final response = await dio.get(
        "${AppUrls.api_url}/api/conversations/${widget.chatId}/messages",
        queryParameters: {
          if (_beforeMessageId != null) 'before': _beforeMessageId,
        },
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer ${AuthService.token}",
          },
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
          response.data is Map
              ? response.data["error"]?.toString() ??
                    "Request failed with status ${response.statusCode}"
              : response.data.toString(),
        );
      }

      final data = response.data;

      final newMessages = (data['data'] as List)
          .map((e) => MessageModel.fromMap(e))
          .toList();

      if (!mounted) return;

      setState(() {
        if (isInitialLoad) {
          messages = newMessages;
        } else {
          messages.insertAll(0, newMessages);
        }

        _hasMoreMessages = data['has_more'] == true;
        _beforeMessageId = data['next_before']?.toString();
      });

      // Initial load → go to bottom
      if (isInitialLoad) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToBottom();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, cleanErrorMessage(e), isError: true);
      }
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _loadingMoreMessages = false;
      });
    }
  }

  void _listenToConversation() async {
    await ReverbService.connect();
    _conversationChannel = ReverbService.client.subscribeToPrivateChannel(
      'private-conversation.${widget.chatId}',
    );

    _conversationChannel.on('message.sent').listen((event) {
      final data = jsonDecode(event.data);
      // logger.i("2222222222222 🔥 Reverb event: ${data}");

      final message = MessageModel.fromMap(
        Map<String, dynamic>.from(data['message']),
      );

      if (!mounted) return;

      setState(() {
        messages.add(message);
        if (mounted) setState(() => _sending = false);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  Future<void> saveFilelocally(MessageModel msg) async {
    try {
      final tempDir = await getTemporaryDirectory();

      final extension = msg.fileUrl!.split('.').last.split('?').first;

      final fileName =
          'chatdtn_${DateFormat('yyyy_MM_dd_HHmmss').format(msg.timestamp)}_${msg.messageId}.$extension';

      final tempPath = '${tempDir.path}/$fileName';

      await Dio().download(
        '${AppUrls.api_url}/storage/${msg.fileUrl}',
        tempPath,
      );

      final mediaStore = MediaStore();

      await mediaStore.saveFile(
        tempFilePath: tempPath,
        dirType: DirType.download,
        dirName: DirName.download,
        relativePath: 'W33_chat',
      );

      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (!context.mounted) return;

      showAppSnackBar(context, 'File saved successfully To /Downloads/W33_chat', isError: false);
    } catch (e) {
      if (!context.mounted) return;

      logger.e('Failed to save file: $e');

      showAppSnackBar(context, 'Failed to save file', isError: true);
    }
  }

  Future<void> deleteMessage(MessageModel msg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await dio.delete(
        '${AppUrls.api_url}/api/messages/${msg.messageId}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (!context.mounted) return;
        final targetId = msg.messageId;

        setState(() {
          messages.removeWhere((item) => item.messageId == targetId);
        });

        showAppSnackBar(
          context,
          'Message deleted successfully',
          isError: false,
        );
      } else {
        throw Exception('Delete failed');
      }
    } catch (e) {
      if (!context.mounted) return;

      showAppSnackBar(context, 'Failed to delete message', isError: true);
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
            UserAvatar(user: user, radius: 18, heroTag: 'avatar_${user.id}'),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                // Text(
                //   user.isOnline ? 'online' : 'last seen ${DateFormat.Hm().format(user.lastSeen)}',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: user.isOnline ? AppColors.online : AppColors.textSecondary,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 20,
                    children: [
                      CircularProgressIndicator(),
                      Text(
                        'Loading messages',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet.\nSay hello! 👋',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: messages.length + (_loadingMoreMessages ? 1 : 0),
                    itemBuilder: (_, i) {
                      // Loading indicator at the very top
                      if (_loadingMoreMessages && i == 0) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        );
                      }

                      final messageIndex = _loadingMoreMessages ? i - 1 : i;
                      final message = messages[messageIndex];

                      return InkWell(
                        onLongPress: () {
                          showBubbleOptionsSheet(
                            context,
                            isself: message.senderId == _myId,
                            istext: message.type.name == "text",
                            onSave: () {
                              saveFilelocally(message);
                            },
                            onDelete: () {
                              deleteMessage(message);
                            },
                          );
                        },
                        child: MessageBubble(
                          message: message,
                          isMe: message.senderId == _myId,
                          playingMessageId: _voice.playingMessageId,
                          onPlayAudio: (url, id) {
                            _voice.togglePlayback(
                              '${AppUrls.api_url}/storage/$url',
                              id,
                              _refresh,
                            );
                          },
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
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _voice.recordingLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Tap stop to send',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sending...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
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
            onCancelRecord: _cancelVoice,
            onTextChanged: _refresh,
          ),
        ],
      ),
    );
  }
}
