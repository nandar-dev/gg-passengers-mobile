import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/widgets/app_message.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _openLink(BuildContext context, Uri uri, String fallbackMessage) async {
    final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      AppMessage.error(context, fallbackMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEAECEF)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  'Choose a support channel and we will assist you quickly.',
                  style: TextStyle(color: Color(0xFF5F6368)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SupportTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Live Chat',
            subtitle: 'Average wait time: under 2 minutes',
            onTap: () => _openLink(
              context,
              Uri.parse('https://ggtaxi.com/support'),
              'Unable to open live chat right now',
            ),
          ),
          const SizedBox(height: 10),
          _SupportTile(
            icon: Icons.call_outlined,
            title: 'Call Support',
            subtitle: '24/7 helpline for urgent ride issues',
            onTap: () => _openLink(
              context,
              Uri(scheme: 'tel', path: '+18001234567'),
              'Unable to open dialer right now',
            ),
          ),
          const SizedBox(height: 10),
          _SupportTile(
            icon: Icons.mail_outline_rounded,
            title: 'Email Support',
            subtitle: 'support@ggtaxi.com',
            onTap: () => _openLink(
              context,
              Uri(
                scheme: 'mailto',
                path: 'support@ggtaxi.com',
                queryParameters: <String, String>{
                  'subject': 'GG Taxi Support',
                },
              ),
              'Unable to open email app right now',
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportTile({
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
