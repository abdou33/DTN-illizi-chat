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

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _hidePass = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signUp(
        name: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ChatsScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) showAppSnackBar(context, cleanErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create Account',
      footer: Center(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text.rich(
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              children: [
                TextSpan(text: 'Log In', style: TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600)),
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
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: AppStyles.inputDecoration(label: 'Full Name', hint: 'Enter your name', prefixIcon: AppIcons.user),
              validator: FormValidators.name,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: AppStyles.inputDecoration(label: 'Phone Number', hint: '+212 6XX XXX XXX', prefixIcon: AppIcons.phone),
              validator: FormValidators.phone,
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
                  icon: Icon(_hidePass ? AppIcons.eyeOff : AppIcons.eye, color: AppColors.textSecondary, size: 22),
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
                  icon: Icon(_hideConfirm ? AppIcons.eyeOff : AppIcons.eye, color: AppColors.textSecondary, size: 22),
                  onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                ),
              ),
              validator: (v) => FormValidators.confirmPassword(v, _passCtrl.text),
            ),
            const SizedBox(height: 32),
            PrimaryButton(label: 'Sign Up', loading: _loading, onPressed: _signUp),
          ],
        ),
      ),
    );
  }
}
