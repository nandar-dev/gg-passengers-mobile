import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchLocationScreen extends StatelessWidget {
  const SearchLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> dummyPlaces = <String>[
      'Airport Terminal 1',
      'City Center Mall',
      'Tech Park Gate 3',
      'MG Road Metro Station',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Search Location')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search destination',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: dummyPlaces.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(dummyPlaces[index]),
                    onTap: () => context.go('/home/ride-category'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
