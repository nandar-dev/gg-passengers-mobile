import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../features/auth/presentation/providers/auth_otp_notifier.dart';
import '../../core/routing/route_names.dart';
import '../../shared/widgets/primary_button.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String phone;

  const OTPVerificationScreen({
    super.key,
    required this.phone,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  Timer? _timer;
  int _secondsLeft = 30;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _otpFocusNode.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _shakeOtpBoxes() {
    _shakeController.forward(from: 0);
  }

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

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length < 6) {
      setState(() => _otpError = 'Please enter a valid 6-digit OTP');
      _shakeOtpBoxes();
      return;
    }

    final notifier = ref.read(verifyPassengerOtpNotifierProvider.notifier);
    final bool isVerified = await notifier.verifyPassengerOtp(
      otpCode: _otpController.text.trim(),
    );

    if (!mounted) return;

    final fieldErrors = notifier.validationErrors();
    if (fieldErrors.isNotEmpty) {
      setState(() {
        _otpError = fieldErrors['otp_code'] ?? _otpError;
      });
      _shakeOtpBoxes();
      return;
    }

    final errorMessage = notifier.toReadableError();
    if (errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    if (isVerified) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('OTP verified successfully')));
    }

    context.go(RouteNames.home);
  }

  PinTheme _pinTheme({
    required Color borderColor,
    Color fillColor = const Color(0xFFFDFDFD),
  }) {
    return PinTheme(
      width: 52,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF202124),
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(verifyPassengerOtpNotifierProvider);
    final bool isLoading = otpState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(height: 10),
              const Text(
                'OTP Verification',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('Enter the 6-digit code sent to ${widget.phone}'),
              const SizedBox(height: 28),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Center(
                  child: Pinput(
                    controller: _otpController,
                    focusNode: _otpFocusNode,
                    autofocus: true,
                    length: 6,
                    keyboardType: TextInputType.number,
                    defaultPinTheme: _pinTheme(
                      borderColor: const Color(0xFFE5E7EB),
                    ),
                    focusedPinTheme: _pinTheme(
                      borderColor: const Color(0xFFFE8C00),
                      fillColor: const Color(0xFFFFFAF3),
                    ),
                    submittedPinTheme: _pinTheme(
                      borderColor: const Color(0xFFFFC978),
                      fillColor: const Color(0xFFFFF6E8),
                    ),
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    validator: (value) {
                      if (_otpError != null) return _otpError;
                      if ((value ?? '').length != 6) return 'Invalid OTP';
                      return null;
                    },
                    onChanged: (_) {
                      if (_otpError != null) {
                        setState(() => _otpError = null);
                      }
                    },
                    onCompleted: (_) {
                      if (!isLoading) {
                        _verifyOtp();
                      }
                    },
                  ),
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
                      onPressed: _startTimer,
                      child: const Text('Resend OTP'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _otpController,
                builder: (context, value, _) {
                  final bool isOtpComplete = value.text.trim().length == 6;
                  return PrimaryButton(
                    label: 'Verify & Continue',
                    isLoading: isLoading,
                    onPressed: isOtpComplete && !isLoading ? _verifyOtp : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
