import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_register_notifier.dart';
import '../../core/routing/route_names.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/primary_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _normalizePhone(_phoneController.text.trim());
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? nameError;
    String? emailError;
    String? phoneError;
    String? passwordError;
    String? confirmPasswordError;

    if (name.isEmpty || name.length < 2) {
      nameError = 'Please enter your full name';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      emailError = 'Please enter a valid email address';
    }

    if (phone.length < 10) {
      phoneError = 'Please enter a valid phone number';
    }

    if (password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }

    if (confirmPassword != password) {
      confirmPasswordError = 'Passwords do not match';
    }

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _phoneError = phoneError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return nameError == null &&
        emailError == null &&
        phoneError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_validateForm()) {
      return;
    }

    final notifier = ref.read(registerPassengerNotifierProvider.notifier);
    final user = await notifier.registerPassenger(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _normalizePhone(_phoneController.text.trim()),
      password: _passwordController.text,
    );

    if (!mounted) return;

    final errorMessage = notifier.toReadableError();
    final fieldErrors = notifier.validationErrors();

    if (fieldErrors.isNotEmpty) {
      setState(() {
        _emailError = fieldErrors['email'] ?? _emailError;
        _phoneError = fieldErrors['phone'] ?? _phoneError;
        _nameError = fieldErrors['name'] ?? _nameError;
        _passwordError = fieldErrors['password'] ?? _passwordError;
      });

      return;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    if (user != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Account created successfully')));

      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerPassengerNotifierProvider);
    final bool isLoading = registerState.isLoading;

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
                'Create Account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Set up your profile to start booking rides'),
              const SizedBox(height: 30),
              PrimaryTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _nameController,
                errorText: _nameError,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              PrimaryTextField(
                label: 'Email',
                hint: 'john@example.com',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                errorText: _emailError,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                },
              ),
              const SizedBox(height: 14),
              PrimaryTextField(
                label: 'Phone Number',
                hint: '98765 43210',
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                errorText: _phoneError,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_phoneError != null) {
                    setState(() => _phoneError = null);
                  }
                },
              ),
              const SizedBox(height: 14),
              PrimaryTextField(
                label: 'Password',
                hint: 'Create password',
                obscureText: true,
                controller: _passwordController,
                errorText: _passwordError,
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
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Create Account',
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
