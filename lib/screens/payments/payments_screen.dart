import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../features/payments/domain/entities/payment_method.dart';
import '../../features/payments/domain/use_cases/get_payment_methods_use_case.dart';
import '../../features/payments/presentation/payment_method_image_widget.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<PaymentMethod> _paymentMethods = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final methods = await getIt<GetPaymentMethodsUseCase>().call(
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;

      setState(() {
        _paymentMethods = methods;
        _isLoading = false;
      });

      // Preload images in background (non-blocking)
      _preloadPaymentMethodImagesBackground(methods);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Unable to load payment methods. Pull to refresh.';
      });
    }
  }

  void _preloadPaymentMethodImagesBackground(List<PaymentMethod> methods) {
    for (final method in methods) {
      if (method.iconUrl.isNotEmpty) {
        try {
          precacheImage(
            CachedNetworkImageProvider(method.iconUrl),
            context,
          );
        } catch (_) {
          // Ignore preload errors - fallback icon will be used
        }
      }
    }
  }

  Widget _buildLeading(PaymentMethod method) {
    return PaymentMethodImageWidget(
      method: method,
      size: 24,
      showBackground: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: RefreshIndicator(
        onRefresh: () => _loadPaymentMethods(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _paymentMethods.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _loadPaymentMethods(forceRefresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else ...[
              ..._paymentMethods.asMap().entries.map((entry) {
                final index = entry.key;
                final method = entry.value;
                return Column(
                  children: [
                    ListTile(
                      leading: _buildLeading(method),
                      title: Text(method.name),
                    ),
                    if (index < _paymentMethods.length - 1) const Divider(),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
