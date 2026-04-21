import 'package:flutter/material.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: const [
          _PromoCard(
            title: 'Welcome Offer',
            code: 'WELCOME50',
            description: 'Get 50% off on your next 2 rides (up to Rs. 120).',
            expiry: 'Valid until 30 Apr 2026',
          ),
          SizedBox(height: 12),
          _PromoCard(
            title: 'Airport Saver',
            code: 'AIRPORT25',
            description: 'Save 25% on airport pick-up and drop rides.',
            expiry: 'Valid until 10 May 2026',
          ),
          SizedBox(height: 12),
          _PromoCard(
            title: 'Night Ride Deal',
            code: 'NIGHT10',
            description: 'Flat 10% off on rides between 10 PM and 6 AM.',
            expiry: 'Valid until 15 May 2026',
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title;
  final String code;
  final String description;
  final String expiry;

  const _PromoCard({
    required this.title,
    required this.code,
    required this.description,
    required this.expiry,
  });

  @override
  Widget build(BuildContext context) {
    const Color brand = Color(0xFFFE8C00);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_rounded, color: brand),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              code,
              style: const TextStyle(
                color: brand,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF5F6368)),
          ),
          const SizedBox(height: 8),
          Text(
            expiry,
            style: const TextStyle(
              color: Color(0xFF7A7A7A),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
