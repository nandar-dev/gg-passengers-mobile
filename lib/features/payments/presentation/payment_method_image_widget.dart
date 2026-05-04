import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../features/payments/domain/entities/payment_method.dart';
import 'payment_method_ui_mapper.dart';

/// Cached network image widget for payment methods with fallback
class PaymentMethodImageWidget extends StatelessWidget {
  final PaymentMethod method;
  final double size;
  final BoxFit fit;
  final bool showBackground;

  const PaymentMethodImageWidget({
    required this.method,
    this.size = 20,
    this.fit = BoxFit.contain,
    this.showBackground = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = paymentMethodFallbackIcon(method.name);
    final fallbackColor = paymentMethodFallbackColor(method.name);

    if (method.iconUrl.isEmpty) {
      return showBackground
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: fallbackColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(fallbackIcon, color: fallbackColor, size: size),
            )
          : Icon(fallbackIcon, color: fallbackColor, size: size);
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: method.iconUrl,
      width: size,
      height: size,
      fit: fit,
      placeholder: (context, url) => SizedBox(
        width: size,
        height: size,
        child: Icon(fallbackIcon, color: fallbackColor, size: size * 0.8),
      ),
      errorWidget: (context, url, error) =>
          Icon(fallbackIcon, color: fallbackColor, size: size),
      cacheKey: 'payment_method_${method.id}',
    );

    if (showBackground) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: fallbackColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
