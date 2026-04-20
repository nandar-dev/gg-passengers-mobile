import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';

class RideReviewScreen extends StatelessWidget {
  const RideReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Your Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text('How was your ride?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFFE8C00), size: 36),
                Icon(Icons.star_rounded, color: Color(0xFFFE8C00), size: 36),
                Icon(Icons.star_rounded, color: Color(0xFFFE8C00), size: 36),
                Icon(Icons.star_rounded, color: Color(0xFFFE8C00), size: 36),
                Icon(Icons.star_border_rounded, color: Color(0xFFFE8C00), size: 36),
              ],
            ),
            const SizedBox(height: 22),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write feedback (dummy)',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
