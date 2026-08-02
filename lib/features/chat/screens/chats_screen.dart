import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dtn_chat/core/constants/app_urls.dart';
import 'package:dtn_chat/core/utils/ui_utils.dart';
import 'package:dtn_chat/data/models/chat_model.dart';
import 'package:dtn_chat/data/models/message_model.dart';
import 'package:dtn_chat/data/services/reverb_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:logger/logger.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/local_db.dart';
import '../../auth/screens/welcome_screen.dart';
import 'new_chat_screen.dart';
import 'profile_screen.dart';
import '../widgets/chat_list_tile.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final _auth = AuthService();
  final _searchCtrl = TextEditingController();
  late final Channel _userChannel;
  bool _searching = false;
  bool _loading = false;
  String _query = '';
  List<ChatModel> chats = [];
  final dio = Dio();
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _getchats();
    _listenForChatUpdates();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    final userId = AuthService.currentUser!.id;

    ReverbService.client.unsubscribeFromChannel('private-user.$userId');
    super.dispose();
  }

  void _listenForChatUpdates() async {
    await ReverbService.connect();
    final userId = AuthService.currentUser!.id;

    _userChannel = ReverbService.client.subscribeToPrivateChannel(
      'private-user.$userId',
    );

    _userChannel.on('message.sent').listen((event) {
      final data = jsonDecode(event.data);

      final message = MessageModel.fromMap(
        Map<String, dynamic>.from(data['message']),
      );

      if (!mounted) return;

      setState(() {
        final index = chats.indexWhere(
          (chat) => chat.chatId == message.conversationId,
        );

        if (index == -1) return;

        final updatedChat = chats[index].copyWith(
          lastMessage: message.content,
          lastMessageType: message.type.name,
          lastMessageTime: message.timestamp,
          unreadCount: chats[index].unreadCount + 1,
        );

        chats.removeAt(index);
        chats.insert(0, updatedChat);
      });
    });
  }

  void _updateChatList(MessageModel message) {
    setState(() {
      // update your ChatModel here
    });
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(AppIcons.profile, color: AppColors.iosBlue),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
              ),
              ListTile(
                leading: const Icon(AppIcons.logout, color: AppColors.error),
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _auth.logout();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (_) => false,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getchats() async {
    setState(() {
      _loading = true;
      chats = [];
    });
    try {
      final response = await dio.get(
        "${AppUrls.api_url}/api/conversations",
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
          validateStatus: (status) => true, // accept all codes
        ),
      );
      // logger.i("response: ${response.data}");
      logger.i("status: ${response.statusCode}");
      logger.i("type: ${response.data.runtimeType}");
      logger.i("data: ${response.data}");

      if (response.statusCode == 200) {
        setState(() {
          chats = (response.data as List)
              .map((e) => ChatModel.fromMap(e))
              .toList();
        });
      } else {
        throw Exception(
          response.data['error']?.toString() ??
              'Request failed with status code ${response.statusCode}',
        );
      }
    } catch (e) {
      // logger.e(e);
      if (mounted) {
        showAppSnackBar(context, cleanErrorMessage(e), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppColors.iosSecondaryBackground,
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              )
            : const Text(
                'Chats',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _searching ? AppIcons.close : AppIcons.search,
              color: AppColors.darkGreen,
            ),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _searchCtrl.clear();
                _query = '';
              }
            }),
          ),
          IconButton(
            icon: const Icon(AppIcons.more, color: AppColors.darkGreen),
            onPressed: _openMenu,
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: _getchats,
        child: _loading
            ? Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    SizedBox(
                      height: 35,
                      width: 35,
                      child: CircularProgressIndicator(),
                    ),
                    const EmptyState(
                      icon: IconsaxPlusLinear.messages_3,
                      title: 'Loading your conversations ;)',
                      subtitle: '',
                    ),
                  ],
                ),
              )
            : chats.isEmpty
            ? const EmptyState(
                icon: AppIcons.chat,
                title: 'No conversations yet',
                subtitle: 'Start a new chat to begin messaging',
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: chats.length,
                itemBuilder: (_, i) =>
                    ChatListTile(chat: chats[i], searchQuery: _query),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewChatScreen()),
        ),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(AppIcons.newChat, color: Colors.white),
      ),
    );
  }
}
