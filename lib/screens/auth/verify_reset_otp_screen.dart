import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';
import '../../features/auth/presentation/providers/auth_verify_reset_otp_notifier.dart';
import '../../shared/widgets/app_message.dart';
import '../../shared/widgets/otp_pin_input.dart';
import '../../shared/widgets/primary_button.dart';

class VerifyResetOtpScreen extends ConsumerStatefulWidget {
  final String? initialLogin;

  const VerifyResetOtpScreen({
    super.key,
    this.initialLogin,
  });

  @override
  ConsumerState<VerifyResetOtpScreen> createState() => _VerifyResetOtpScreenState();
}

class _VerifyResetOtpScreenState extends ConsumerState<VerifyResetOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 30;

  String? _otpError;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  String get _login => widget.initialLogin?.trim() ?? '';

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  bool _validate() {
    final otp = _otpController.text.trim();

    String? otpError;

    if (otp.length != 6) {
      otpError = 'Please enter a valid 6-digit OTP';
    }

    setState(() {
      _otpError = otpError;
    });

    return otpError == null;
  }

  Future<void> _resendOtp() async {
    final login = _login;
    if (login.isEmpty) {
      AppMessage.error(context, 'Missing email. Please restart forgot password flow.');
      return;
    }

    final notifier = ref.read(verifyPassengerResetOtpNotifierProvider.notifier);
    final isResent = await notifier.resendResetOtp(login: login);

    if (!mounted) return;

    final errorMessage = notifier.toReadableError();
    if (!isResent || errorMessage != null) {
      AppMessage.error(context, errorMessage ?? 'Unable to resend OTP. Please try again.');
      return;
    }

    _startTimer();
    AppMessage.success(context, 'OTP sent to your email');
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final login = _login;
    if (login.isEmpty) {
      AppMessage.error(context, 'Missing email. Please restart forgot password flow.');
      return;
    }

    if (!_validate()) {
      return;
    }

    final notifier = ref.read(verifyPassengerResetOtpNotifierProvider.notifier);
    final resetToken = await notifier.verifyResetOtp(
      login: login,
      otp: _otpController.text.trim(),
    );

    if (!mounted) return;

    final fieldErrors = notifier.validationErrors();
    if (fieldErrors.isNotEmpty) {
      setState(() {
        _otpError = fieldErrors['otp'] ?? _otpError;
      });
      return;
    }

    final errorMessage = notifier.toReadableError();
    if (errorMessage != null) {
      AppMessage.error(context, errorMessage);
      return;
    }

    if (resetToken != null && resetToken.isNotEmpty) {
      AppMessage.success(context, 'OTP verified successfully');

      context.go(
        RouteNames.resetPassword,
        extra: <String, String>{
          'login': login,
          'resetToken': resetToken,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifyState = ref.watch(verifyPassengerResetOtpNotifierProvider);
    final isLoading = verifyState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go(RouteNames.forgotPassword),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verify OTP',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _login.isNotEmpty
                    ? 'Enter the OTP sent to your email "$_login"'
                    : 'Enter the OTP sent to your email',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.go(RouteNames.forgotPassword, extra: _login),
                  child: const Text('Edit email'),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'OTP Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C4043),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: OtpPinInput(
                  controller: _otpController,
                  autofocus: true,
                  enabled: !isLoading,
                  errorText: _otpError,
                  onChanged: (_) {
                    if (_otpError != null) {
                      setState(() => _otpError = null);
                    }
                  },
                  onCompleted: (_) {
                    if (!isLoading) {
                      _submit();
                    }
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Didn\'t receive code? '),
                  if (_secondsLeft > 0)
                    Text('Resend in ${_secondsLeft}s')
                  else
                    TextButton(
                      onPressed: isLoading ? null : _resendOtp,
                      child: const Text('Resend OTP'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Verify OTP',
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
