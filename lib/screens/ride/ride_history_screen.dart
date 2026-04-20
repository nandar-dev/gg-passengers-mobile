import 'package:flutter/material.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> rides = <Map<String, String>>[
      <String, String>{'route': 'Airport -> MG Road', 'date': '08 Apr', 'fare': 'Rs. 320'},
      <String, String>{'route': 'Tech Park -> Home', 'date': '06 Apr', 'fare': 'Rs. 190'},
      <String, String>{'route': 'Mall -> Station', 'date': '03 Apr', 'fare': 'Rs. 140'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ride History')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final ride = rides[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_rounded),
              title: Text(ride['route']!),
              subtitle: Text(ride['date']!),
              trailing: Text(ride['fare']!),
            ),
          );
        },
      ),
    );
  }
}
