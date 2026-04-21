import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';
import '../../features/auth/presentation/providers/auth_reset_password_notifier.dart';
import '../../shared/widgets/app_message.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/primary_text_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? initialLogin;
  final String? resetToken;

  const ResetPasswordScreen({
    super.key,
    this.initialLogin,
    this.resetToken,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _tokenError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _login => widget.initialLogin?.trim() ?? '';

  bool _validate() {
    final login = _login;
    final resetToken = widget.resetToken?.trim() ?? '';
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? tokenError;
    String? newPasswordError;
    String? confirmPasswordError;

    if (login.isEmpty) {
      tokenError = 'Missing email context. Please verify OTP again.';
    }

    if (resetToken.isEmpty) {
      tokenError = 'Reset token is missing. Please verify OTP again.';
    }

    if (newPassword.length < 6) {
      newPasswordError = 'Password must be at least 6 characters';
    }

    if (confirmPassword != newPassword) {
      confirmPasswordError = 'Passwords do not match';
    }

    setState(() {
      _tokenError = tokenError;
      _newPasswordError = newPasswordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return tokenError == null &&
        newPasswordError == null &&
        confirmPasswordError == null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_validate()) {
      return;
    }

    final notifier = ref.read(resetPassengerPasswordNotifierProvider.notifier);
    final success = await notifier.resetPassword(
      login: _login,
      resetToken: widget.resetToken!.trim(),
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;

    final fieldErrors = notifier.validationErrors();
    if (fieldErrors.isNotEmpty) {
      setState(() {
        _tokenError = fieldErrors['login'] ?? _tokenError;
        _tokenError = fieldErrors['reset_token'] ?? _tokenError;
        _newPasswordError = fieldErrors['new_password'] ?? _newPasswordError;
        _confirmPasswordError = fieldErrors['new_password_confirmation'] ?? _confirmPasswordError;
      });
      return;
    }

    final errorMessage = notifier.toReadableError();
    if (errorMessage != null) {
      AppMessage.error(context, errorMessage);
      return;
    }

    if (success) {
      AppMessage.success(context, 'Password reset successfully');

      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(resetPassengerPasswordNotifierProvider);
    final isLoading = resetState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go(RouteNames.login),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reset Password',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Create your new password'),
              const SizedBox(height: 30),
              if (_tokenError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _tokenError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              PrimaryTextField(
                label: 'New Password',
                hint: 'Create new password',
                obscureText: true,
                controller: _newPasswordController,
                errorText: _newPasswordError,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              PrimaryTextField(
                label: 'Confirm Password',
                hint: 'Re-enter password',
                obscureText: true,
                controller: _confirmPasswordController,
                errorText: _confirmPasswordError,
                enabled: !isLoading,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Reset Password',
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
