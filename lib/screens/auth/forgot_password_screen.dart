import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';
import '../../features/auth/presentation/providers/auth_forgot_password_notifier.dart';
import '../../shared/widgets/app_message.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/primary_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String? initialLogin;

  const ForgotPasswordScreen({
    super.key,
    this.initialLogin,
  });

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController _loginController;

  String? _loginError;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController(text: widget.initialLogin ?? '');
  }

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  bool _validate() {
    final login = _loginController.text.trim();

    String? loginError;
    if (login.isEmpty) {
      loginError = 'Please enter email or phone number';
    }

    setState(() {
      _loginError = loginError;
    });

    return loginError == null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_validate()) {
      return;
    }

    final notifier = ref.read(forgotPassengerPasswordNotifierProvider.notifier);
    final success = await notifier.forgotPassword(
      login: _loginController.text.trim(),
    );

    if (!mounted) return;

    final fieldErrors = notifier.validationErrors();
    if (fieldErrors.isNotEmpty) {
      setState(() {
        _loginError = fieldErrors['login'] ?? _loginError;
      });
      return;
    }

    final errorMessage = notifier.toReadableError();
    if (errorMessage != null) {
      AppMessage.error(context, errorMessage);
      return;
    }

    if (success) {
      final login = _loginController.text.trim();

      AppMessage.success(context, 'OTP sent to your email');

      context.go(RouteNames.verifyResetOtp, extra: login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final forgotState = ref.watch(forgotPassengerPasswordNotifierProvider);
    final isLoading = forgotState.isLoading;

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
                'Forgot Password',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Enter your email or phone to receive reset OTP'),
              const SizedBox(height: 30),
              PrimaryTextField(
                label: 'Email or Phone',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                controller: _loginController,
                errorText: _loginError,
                enabled: !isLoading,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_loginError != null) {
                    setState(() => _loginError = null);
                  }
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Send OTP',
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
