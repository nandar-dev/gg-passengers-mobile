import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('John Doe'),
            subtitle: Text('john@example.com'),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () => context.go(RouteNames.settings),
          ),
          ListTile(
            leading: const Icon(Icons.payment_rounded),
            title: const Text('Payments'),
            onTap: () => context.go(RouteNames.payments),
          ),
        ],
      ),
    );
  }
}
