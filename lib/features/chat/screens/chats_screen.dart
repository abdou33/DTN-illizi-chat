import 'package:flutter/material.dart';
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
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
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
                title: const Text('Log Out', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  // await _auth.logOut();
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
                decoration: const InputDecoration(hintText: 'Search...', border: InputBorder.none),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              )
            : const Text('Chats', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(_searching ? AppIcons.close : AppIcons.search, color: AppColors.darkGreen),
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
      body: ListenableBuilder(
        listenable: LocalDb(),
        builder: (_, __) {
          final chats = LocalDb().chats;
          if (chats.isEmpty) {
            return const EmptyState(
              icon: AppIcons.chat,
              title: 'No conversations yet',
              subtitle: 'Start a new chat to begin messaging',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: chats.length,
            itemBuilder: (_, i) => ChatListTile(chat: chats[i], searchQuery: _query),
          );
        },
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
