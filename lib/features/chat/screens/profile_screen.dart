import 'dart:io';
import 'package:dtn_chat/core/widgets/primary_button.dart';
import 'package:dtn_chat/features/chat/screens/change_pwd_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosGroupedBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Builder(
        builder: (_) {
          final user = AuthService.currentUser;
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    //_changePhoto(context, user);
                  },
                  child: Stack(
                    children: [
                      UserAvatar(user: user, radius: 60),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          // child: const Icon(
                          //   AppIcons.camera,
                          //   color: Colors.white,
                          //   size: 18,
                          // ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user.phonenumber,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),
                _InfoCard(
                  user: user,
                  onEdit: (field) => _editField(context, user, field),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PrimaryButton(
                    label: 'change password',
                    loading: false,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const ChangePwdScreen(canignore: false),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _changePhoto(BuildContext context, UserModel user) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file == null) return;
    try {
      final url = await _storage.uploadProfileImage(File(file.path));
      // await _auth.updateProfile(profileImageUrl: url);
    } catch (_) {
      if (context.mounted)
        showAppSnackBar(context, 'Failed to update photo', isError: true);
    }
  }

  Future<void> _editField(
    BuildContext context,
    UserModel user,
    String field,
  ) async {
    final current = field == 'name' ? user.name : (user.id ?? '');
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${field == 'name' ? 'Name' : 'About'}'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty || result == current) return;
    if (field == 'name') {
      // await _auth.updateProfile(name: result);
    } else {
      // await _auth.updateProfile(about: result);
    }
  }
}

class _InfoCard extends StatelessWidget {
  final UserModel user;
  final void Function(String field) onEdit;

  const _InfoCard({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            _Row(AppIcons.user, 'Name', user.name, () => onEdit('name')),
            const Divider(height: 1, indent: 56),
            // _Row(
            //   AppIcons.info,
            //   'About',
            //   user.id ?? 'Hey there! I am using DTN Chat',
            //   () => onEdit('about'),
            // ),
            const Divider(height: 1, indent: 56),
            _Row(AppIcons.phone, 'Phone', user.phonenumber, null),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _Row(this.icon, this.label, this.value, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkGreen),
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
      subtitle: Text(value),
      // trailing: onTap != null
      //     ? const Icon(AppIcons.edit, size: 18, color: AppColors.textSecondary)
      //     : null,
      // onTap: onTap,
    );
  }
}
