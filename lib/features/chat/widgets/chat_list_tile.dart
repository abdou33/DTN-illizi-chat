import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/chat_service.dart';
import '../screens/conversation_screen.dart';

class ChatListTile extends StatelessWidget {
  final ChatModel chat;
  final String searchQuery;

  const ChatListTile({super.key, required this.chat, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: ChatService().getOtherUser(chat),
      builder: (context, snap) {
        final user = snap.data;
        if (user == null) return const SizedBox.shrink();

        final q = searchQuery.toLowerCase();
        if (q.isNotEmpty &&
            !user.name.toLowerCase().contains(q) &&
            !user.phoneNumber.contains(searchQuery)) {
          return const SizedBox.shrink();
        }

        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConversationScreen(otherUser: user, chatId: chat.chatId),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                UserAvatar(user: user, heroTag: 'avatar_${user.uid}'),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            formatChatTime(chat.lastMessageTime),
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat.lastMessage.isEmpty ? 'Start chatting' : chat.lastMessage,
                        style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
