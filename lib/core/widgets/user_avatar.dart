import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../constants/app_colors.dart';
import '../utils/media_utils.dart';
import '../utils/name_utils.dart';

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;
  final String? heroTag;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 28,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
      backgroundImage: mediaImageProvider(user.profileImageUrl),
      child: user.profileImageUrl == null
          ? Text(
              nameInitials(user.name),
              style: TextStyle(
                fontSize: radius * 0.78,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            )
          : null,
    );

    if (heroTag == null) return avatar;
    return Hero(tag: heroTag!, child: avatar);
  }
}
