import 'package:dio/dio.dart';
import 'package:dtn_whatsapp_clone/core/constants/app_urls.dart';
import 'package:dtn_whatsapp_clone/data/services/token_service.dart';
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
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true, // accept all codes
        ),
      );

      if (response.statusCode == 200) {
        bool tokenissaved = await TokenService.add_token(
          response.data['token'],
        );
        if (!tokenissaved) {
          throw Exception('an error was thrown when saving the login token');
        }
      } else {
        throw Exception(
          response.data['error']?.toString() ??
              'Request failed with status code ${response.statusCode}',
        );
      }
      // await _auth.logIn(
      //   phoneNumber: _phoneCtrl.text.trim(),
      //   password: _passCtrl.text,
      // );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ChatsScreen()),
        (_) => false,
      );
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
          onPressed: () => Navigator.pop(context),
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
