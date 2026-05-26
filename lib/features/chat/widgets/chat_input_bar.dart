import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  final VoidCallback onToggleRecord;
  final VoidCallback onTextChanged;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isRecording,
    required this.onAttach,
    required this.onSend,
    required this.onToggleRecord,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.iosSecondaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(AppIcons.attach, color: AppColors.darkGreen, size: 28),
            onPressed: onAttach,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.iosGroupedBackground,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                readOnly: isRecording,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: isRecording ? 'Recording voice message...' : 'Message',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onChanged: (_) => onTextChanged(),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: hasText ? onSend : onToggleRecord,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasText
                    ? AppColors.primaryGreen
                    : (isRecording ? AppColors.error : AppColors.primaryGreen),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasText ? AppIcons.send : (isRecording ? AppIcons.stop : AppIcons.mic),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
