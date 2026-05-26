import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/local_db.dart';
import 'conversation_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _auth = AuthService();
  final _chat = ChatService();
  final _searchCtrl = TextEditingController();
  List<UserModel> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    final users = await _auth.searchUsers(query.trim());
    if (mounted) setState(() { _results = users; _searching = false; });
  }

  Future<void> _openChat(UserModel user) async {
    final chatId = await _chat.getOrCreateChat(user.uid);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ConversationScreen(otherUser: user, chatId: chatId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosGroupedBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Chat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search by name or phone',
                prefixIcon: const Icon(AppIcons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.iosGroupedBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _searchCtrl.text.isNotEmpty
                ? _buildSearchResults()
                : ListenableBuilder(
                    listenable: LocalDb(),
                    builder: (_, __) => _buildUserList(_auth.otherUsers),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searching) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No users found', style: TextStyle(color: AppColors.textSecondary)));
    }
    return _buildUserList(_results);
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(child: Text('No users yet', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (_, i) {
        final user = users[i];
        return ListTile(
          leading: UserAvatar(user: user, radius: 24),
          title: Text(user.name),
          subtitle: Text(user.phoneNumber, style: const TextStyle(color: AppColors.textSecondary)),
          onTap: () => _openChat(user),
        );
      },
    );
  }
}
