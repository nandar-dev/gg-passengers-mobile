import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/widgets/app_message.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openExternalPage(
    BuildContext context,
    String url,
    String errorMessage,
  ) async {
    final bool launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      AppMessage.error(context, errorMessage);
    }
  }

  Future<String> _appVersionText() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return 'Passenger App Version ${packageInfo.version} (${packageInfo.buildNumber})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEAECEF)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFFFE3BF),
                  child: Icon(Icons.local_taxi_rounded, color: Color(0xFFFE8C00), size: 30),
                ),
                const SizedBox(height: 10),
                const Text(
                  'GG Taxi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                FutureBuilder<String>(
                  future: _appVersionText(),
                  builder: (context, snapshot) {
                    final String text = snapshot.data ?? 'Passenger App Version';
                    return Text(
                      text,
                      style: const TextStyle(color: Color(0xFF5F6368)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _AboutInfoTile(
            icon: Icons.verified_user_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we process and protect your data',
            onTap: () => _openExternalPage(
              context,
              'https://ggtaxi.com/privacy',
              'Unable to open privacy policy right now',
            ),
          ),
          const SizedBox(height: 10),
          _AboutInfoTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Rules and responsibilities for using GG Taxi',
            onTap: () => _openExternalPage(
              context,
              'https://ggtaxi.com/terms',
              'Unable to open terms right now',
            ),
          ),
          const SizedBox(height: 10),
          _AboutInfoTile(
            icon: Icons.gavel_outlined,
            title: 'Licenses',
            subtitle: 'Open source licenses and acknowledgements',
            onTap: () => _openExternalPage(
              context,
              'https://ggtaxi.com/licenses',
              'Unable to open licenses right now',
            ),

          ),
        ],
      ),
    );
  }
}

class _AboutInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AboutInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAECEF)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF202124)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF5F6368),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
