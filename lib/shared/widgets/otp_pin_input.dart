import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpPinInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpPinInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.onCompleted,
  });

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
    return Pinput(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      length: 6,
      keyboardType: TextInputType.number,
      enabled: enabled,
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
        if (errorText != null) return errorText;
        if ((value ?? '').length != 6) return 'Invalid OTP';
        return null;
      },
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
