import 'package:wilaya_illizi_chat/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/chat_service.dart';

class ChatListTile extends StatelessWidget {
  final ChatModel chat;
  final String searchQuery;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.searchQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final user = snap.data;
    final user = chat.participants.firstWhere(
      (u) => u.id != AuthService.currentUser!.id,
    );
    if (user == null) return const SizedBox.shrink();

    final q = searchQuery.toLowerCase();
    if (q.isNotEmpty &&
        !user.name.toLowerCase().contains(q) &&
        !user.phonenumber.contains(searchQuery)) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            UserAvatar(user: user, heroTag: 'avatar_${user.id}'),
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
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage.isEmpty
                              ? 'Start chatting'
                              : chat.lastMessage,
                          style: chat.unreadCount > 0
                              ? TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                )
                              : TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.normal,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.iosBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
