import 'package:dio/dio.dart';
import 'package:dtn_chat/core/constants/app_urls.dart';
import 'package:dtn_chat/data/services/shared_preferences_service.dart';
import 'package:dtn_chat/features/auth/screens/log_in_screen.dart';
import 'package:dtn_chat/features/auth/widgets/auth_scaffold.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/services/auth_service.dart';
import '../../chat/screens/chats_screen.dart';

class ChangePwdScreen extends StatefulWidget {
  final bool canignore;
  const ChangePwdScreen({super.key, required this.canignore});

  @override
  State<ChangePwdScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<ChangePwdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentpassCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _hidecurrentPass = true;
  bool _hidePass = true;
  bool _hideConfirm = true;
  final dio = Dio();

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changepassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final response = await dio.post(
        "${AppUrls.api_url}/api/change-password",
        data: {
          'current_password': _currentpassCtrl.text,
          'password': _passCtrl.text,
          'password_confirmation': _confirmCtrl.text
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
          validateStatus: (status) => true, // accept all codes
        ),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ChatsScreen()),
          (_) => false,
        );
      } else {
        throw Exception(
          response.data['error']?.toString() ??
              'Request failed with status code ${response.statusCode}',
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ChatsScreen()),
        (_) => false,
      );
    } catch (e) {
      print(e);
      if (mounted)
        showAppSnackBar(context, cleanErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Change password',
      footer: widget.canignore
          ? Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ChatsScreen()),
                  (_) => false,
                ),
                child: const Text.rich(
                  TextSpan(
                    text: 'ignore',
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _currentpassCtrl,
              obscureText: _hidecurrentPass,
              decoration: AppStyles.inputDecoration(
                label: 'Current password',
                hint: 'At least 6 characters',
                prefixIcon: AppIcons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidecurrentPass ? AppIcons.eyeOff : AppIcons.eye,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  onPressed: () =>
                      setState(() => _hidecurrentPass = !_hidecurrentPass),
                ),
              ),
              validator: FormValidators.password,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passCtrl,
              obscureText: _hidePass,
              decoration: AppStyles.inputDecoration(
                label: 'Password',
                hint: 'At least 6 characters',
                prefixIcon: AppIcons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePass ? AppIcons.eyeOff : AppIcons.eye,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _hidePass = !_hidePass),
                ),
              ),
              validator: FormValidators.password,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _hideConfirm,
              decoration: AppStyles.inputDecoration(
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                prefixIcon: AppIcons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _hideConfirm ? AppIcons.eyeOff : AppIcons.eye,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                ),
              ),
              validator: (v) =>
                  FormValidators.confirmPassword(v, _passCtrl.text),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Sign Up',
              loading: _loading,
              onPressed: _changepassword,
            ),
          ],
        ),
      ),
    );
  }
}
