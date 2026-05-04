import 'package:flutter/material.dart';

IconData paymentMethodFallbackIcon(String name) {
  final normalized = name.toLowerCase();
  if (normalized.contains('cash')) {
    return Icons.money_rounded;
  }
  if (normalized.contains('card')) {
    return Icons.credit_card_rounded;
  }
  if (normalized.contains('wallet') || normalized.contains('pay')) {
    return Icons.account_balance_wallet_rounded;
  }
  if (normalized.contains('upi')) {
    return Icons.qr_code_2_rounded;
  }
  return Icons.payments_rounded;
}

Color paymentMethodFallbackColor(String name) {
  final normalized = name.toLowerCase();
  if (normalized.contains('cash')) {
    return Colors.green;
  }
  if (normalized.contains('card')) {
    return Colors.blue;
  }
  if (normalized.contains('wallet') || normalized.contains('pay')) {
    return const Color(0xFFFE8C00);
  }
  if (normalized.contains('upi')) {
    return const Color(0xFF5E35B1);
  }
  return Colors.black54;
}
