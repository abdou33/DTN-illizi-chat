import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';

void showAttachmentSheet(
  BuildContext context, {
  required VoidCallback onGallery,
  required VoidCallback onCamera,
  required VoidCallback onVideo,
  required VoidCallback onDocument,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.iosSeparator,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Option(AppIcons.gallery, 'Gallery', AppColors.primaryGreen, () {
                    Navigator.pop(ctx);
                    onGallery();
                  }),
                  _Option(AppIcons.camera, 'Camera', AppColors.iosBlue, () {
                    Navigator.pop(ctx);
                    onCamera();
                  }),
                  _Option(AppIcons.video, 'Video', Colors.purple, () {
                    Navigator.pop(ctx);
                    onVideo();
                  }),
                  _Option(AppIcons.document, 'Document', Colors.orange, () {
                    Navigator.pop(ctx);
                    onDocument();
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Option(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
