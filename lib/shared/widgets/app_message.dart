import 'package:flutter/material.dart';

class AppMessage {
  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      background: const Color(0xFFEAF8EF),
      foreground: const Color(0xFF136A37),
      icon: Icons.check_circle_rounded,
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      background: const Color(0xFFFDECEC),
      foreground: const Color(0xFFB3261E),
      icon: Icons.error_rounded,
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      background: const Color(0xFFEFF4FF),
      foreground: const Color(0xFF1A56DB),
      icon: Icons.info_rounded,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color background,
    required Color foreground,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(milliseconds: 2200),
          content: Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
