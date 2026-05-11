import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/route_names.dart';
import '../../features/profile/domain/use_cases/get_passenger_profile_use_case.dart';
import '../../shared/widgets/skeleton.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _profileNameKey = 'profile.full_name';
  static const String _profileEmailKey = 'profile.email';

  String _name = 'John Doe';
  String _email = 'john@example.com';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await getIt<GetPassengerProfileUseCase>().call();
      if (!mounted) return;
      setState(() {
        _name = profile.name.trim().isEmpty ? _name : profile.name.trim();
        _email = profile.email.trim().isEmpty ? _email : profile.email.trim();
        _isLoading = false;
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileNameKey, _name);
      await prefs.setString(_profileEmailKey, _email);
    } catch (_) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedName = prefs.getString(_profileNameKey);
      final String? cachedEmail = prefs.getString(_profileEmailKey);
      if (!mounted) return;
      setState(() {
        if (cachedName != null && cachedName.trim().isNotEmpty) {
          _name = cachedName.trim();
        }
        if (cachedEmail != null && cachedEmail.trim().isNotEmpty) {
          _email = cachedEmail.trim();
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _isLoading
                ? const Padding(
                    key: ValueKey('profile-skeleton'),
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: SkeletonListTile(),
                  )
                : ListTile(
                    key: const ValueKey('profile-content'),
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(_name),
                    subtitle: Text(_email),
                  ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Profile'),
            onTap: () => context.push(RouteNames.profileEdit),
          ),
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
