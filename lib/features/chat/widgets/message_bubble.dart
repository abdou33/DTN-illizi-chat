import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/media_utils.dart';
import '../../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final void Function(String url, String messageId) onPlayAudio;
  final String? playingMessageId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onPlayAudio,
    this.playingMessageId,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(top: 4, bottom: 4, left: isMe ? 60 : 0, right: isMe ? 0 : 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.senderBubble : AppColors.receiverBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _MessageContent(
              message: message,
              playingMessageId: playingMessageId,
              onPlayAudio: onPlayAudio,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.Hm().format(message.timestamp),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? AppIcons.read : AppIcons.sent,
                    size: 14,
                    color: message.isRead ? AppColors.iosBlue : AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final MessageModel message;
  final String? playingMessageId;
  final void Function(String url, String messageId) onPlayAudio;

  const _MessageContent({
    required this.message,
    required this.playingMessageId,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(message.content, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary));
      case MessageType.image:
        final path = message.fileUrl ?? message.content;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isLocalMediaPath(path)
              ? Image.file(File(path), width: 220, fit: BoxFit.cover)
              : Image.network(path, width: 220, fit: BoxFit.cover),
        );
      case MessageType.video:
        return _MediaRow(
          icon: AppIcons.play,
          title: message.fileName ?? 'Video',
          subtitle: 'Tap to play',
        );
      case MessageType.audio:
        final isPlaying = playingMessageId == message.messageId;
        final label = message.audioDurationMs != null
            ? formatAudioMs(message.audioDurationMs!)
            : 'Voice message';
        return GestureDetector(
          onTap: () => onPlayAudio(message.fileUrl ?? message.content, message.messageId),
          child: _MediaRow(
            icon: isPlaying ? AppIcons.pause : AppIcons.play,
            title: isPlaying ? 'Playing...' : label,
            subtitle: 'Voice message',
            iconSize: 36,
          ),
        );
      case MessageType.document:
        return _MediaRow(
          icon: AppIcons.document,
          title: message.fileName ?? 'Document',
          subtitle: message.fileSizeBytes != null
              ? '${(message.fileSizeBytes! / 1024).toStringAsFixed(1)} KB'
              : 'Document',
          iconColor: Colors.orange,
        );
    }
  }
}

class _MediaRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double iconSize;
  final Color? iconColor;

  const _MediaRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconSize = 40,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.darkGreen, size: iconSize),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
