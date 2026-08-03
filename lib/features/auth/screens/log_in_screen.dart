import 'package:dio/dio.dart';
import 'package:dtn_chat/core/constants/app_urls.dart';
import 'package:dtn_chat/data/services/shared_preferences_service.dart';
import 'package:dtn_chat/features/auth/screens/register_screen.dart';
import 'package:dtn_chat/features/chat/screens/change_pwd_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/services/auth_service.dart';
import '../widgets/auth_scaffold.dart';
import '../../chat/screens/chats_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _hidePass = true;

  final dio = Dio();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final response = await dio.post(
        "${AppUrls.api_url}/api/login",
        data: {
          'phonenumber': _phoneCtrl.text.trim(),
          'password': _passCtrl.text,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true, // accept all codes
        ),
      );

      if (response.statusCode == 200) {
        print("response:::: ${response.data}");
        await _auth.login(
          user: response.data["user"],
          token: response.data['token'],
        );
      } else {
        throw Exception(
          response.data['error']?.toString() ??
              'Request failed with status code ${response.statusCode}',
        );
      }
      if (!mounted) return;
      if (response.data["user"]["pwd_changable"] == 1) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const ChangePwdScreen(canignore: true),
          ),
          (_) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ChatsScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted)
        showAppSnackBar(context, cleanErrorMessage(e), isError: true);
      print(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'DTN Chat',
      footer: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
            (_) => false,
          ),
          child: const Text.rich(
            TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              children: [
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: AppStyles.inputDecoration(
                label: 'Phone Number',
                hint: '06XX XXX XXX',
                prefixIcon: AppIcons.phone,
              ),
              validator: FormValidators.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passCtrl,
              obscureText: _hidePass,
              decoration: AppStyles.inputDecoration(
                label: 'Password',
                hint: 'Enter your password',
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
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter your password' : null,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Log In',
              loading: _loading,
              onPressed: _logIn,
            ),
          ],
        ),
      ),
    );
  }
}
