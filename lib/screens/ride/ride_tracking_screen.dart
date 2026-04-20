import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RideTrackingScreen extends StatelessWidget {
  const RideTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7EC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('Map Placeholder')),
            ),
            const SizedBox(height: 16),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Driver: Aman Kumar'),
              subtitle: Text('Car: White Swift • KA 01 AB 1234'),
              trailing: Text('6 min'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/home/ride-review'),
                child: const Text('Complete Ride (Dummy)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
