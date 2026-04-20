import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RideCategoryScreen extends StatelessWidget {
  const RideCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = <Map<String, String>>[
      <String, String>{'name': 'Economy', 'eta': '3 min', 'fare': 'Rs. 149'},
      <String, String>{'name': 'Comfort', 'eta': '5 min', 'fare': 'Rs. 219'},
      <String, String>{'name': 'XL', 'eta': '7 min', 'fare': 'Rs. 299'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Ride')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = categories[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.local_taxi_rounded),
              title: Text(item['name']!),
              subtitle: Text('ETA: ${item['eta']}'),
              trailing: Text(item['fare']!, style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => context.go('/home/ride-tracking'),
            ),
          );
        },
      ),
    );
  }
}
