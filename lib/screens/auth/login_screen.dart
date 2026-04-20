import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_login_notifier.dart';
import '../../core/routing/route_names.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/primary_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _loginError;
  String? _passwordError;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    String? loginError;
    String? passwordError;

    if (_loginController.text.trim().isEmpty) {
      loginError = 'Please enter email or phone number';
    }

    if (_passwordController.text.isEmpty) {
      passwordError = 'Please enter your password';
    }

    setState(() {
      _loginError = loginError;
      _passwordError = passwordError;
    });

    return loginError == null && passwordError == null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_validate()) return;

    final notifier = ref.read(loginPassengerNotifierProvider.notifier);
    final session = await notifier.loginPassenger(
      login: _loginController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    final fieldErrors = notifier.validationErrors();
    if (fieldErrors.isNotEmpty) {
      setState(() {
        _loginError = fieldErrors['login'] ?? _loginError;
        _passwordError = fieldErrors['password'] ?? _passwordError;
      });
      return;
    }

    final errorMessage = notifier.toReadableError();
    if (errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    if (session != null) {
      context.go(
        RouteNames.otpVerification,
        extra: <String, String>{
          'phone': session.passenger.phoneNumber,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginPassengerNotifierProvider);
    final bool isLoading = loginState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Sign in with your email or phone number to continue'),
              const SizedBox(height: 34),
              PrimaryTextField(
                label: 'Email or Phone',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                controller: _loginController,
                errorText: _loginError,
                enabled: !isLoading,
                onChanged: (_) {
                  if (_loginError != null) {
                    setState(() => _loginError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              PrimaryTextField(
                label: 'Password',
                hint: 'Enter your password',
                obscureText: true,
                controller: _passwordController,
                errorText: _passwordError,
                enabled: !isLoading,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Continue',
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New to GG TAXI? '),
                  TextButton(
                    onPressed: () => context.go(RouteNames.signup),
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
