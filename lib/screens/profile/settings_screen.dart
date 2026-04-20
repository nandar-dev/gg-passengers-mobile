import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _pushNotificationsKey = 'settings.push_notifications';
  static const String _tripAlertsKey = 'settings.trip_alerts';
  static const String _biometricLockKey = 'settings.biometric_lock';

  bool _pushNotifications = true;
  bool _tripAlerts = true;
  bool _biometricLock = false;
  String _selectedLanguage = 'English';
  String _selectedPayment = 'UPI';

  final List<String> _savedPlaces = <String>['Home', 'Office'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _pushNotifications = prefs.getBool(_pushNotificationsKey) ?? true;
      _tripAlerts = prefs.getBool(_tripAlertsKey) ?? true;
      _biometricLock = prefs.getBool(_biometricLockKey) ?? false;
    });
  }

  Future<void> _saveBoolSetting(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _hapticTap() {
    HapticFeedback.selectionClick();
  }

  void _hapticSuccess() {
    HapticFeedback.lightImpact();
  }

  void _hapticWarning() {
    HapticFeedback.mediumImpact();
  }

  Widget _animatedSection({required Widget child}) {
    return child;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _showSelectionSheet({
    required String title,
    required IconData icon,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    final String? value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFFFE8C00)),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option),
                    trailing: option == selected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFE8C00))
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (value != null && value != selected) {
      _hapticTap();
      setState(() => onSelected(value));
      _showMessage('$title updated to $value');
    }
  }

  Future<void> _showSavedPlacesSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.place_outlined, color: Color(0xFFFE8C00)),
                    SizedBox(width: 10),
                    Text(
                      'Saved Places',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._savedPlaces.map(
                  (place) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(place),
                    subtitle: Text('Tap to edit $place address'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      _hapticTap();
                      Navigator.of(context).pop();
                      _showMessage('$place editing screen will be added next');
                    },
                  ),
                ),
                const Divider(height: 18),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFE8C00),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _hapticTap();
                    Navigator.of(context).pop();
                    _showMessage('Add new place flow will be added next');
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add New Place'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showInfoSheet({
    required String title,
    required IconData icon,
    required String description,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFFFE8C00)),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF5F6368),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFE8C00),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to sign out from this device?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFE8C00)),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      _hapticSuccess();
      _showMessage('Logged out successfully');
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'This action is permanent and cannot be undone. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _hapticWarning();
      _showMessage('Account deletion request submitted');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color pageBackground = Color(0xFFF2F4F7);
    const Color brand = Color(0xFFFE8C00);

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: pageBackground,
        foregroundColor: const Color(0xFF202124),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF202124),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          _animatedSection(
            child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEAECEF), width: 1),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFFFE3BF),
                  child: Icon(
                    Icons.person_rounded,
                    color: brand,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'john@example.com',
                        style: TextStyle(color: Color(0xFF5F6368)),
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE2C0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_rounded, color: brand, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Notifications'),
          _animatedSection(
            child: _SettingsCard(
            child: Column(
              children: [
                _ToggleSettingsTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Offers, updates and app alerts',
                  value: _pushNotifications,
                  onChanged: (value) {
                    _hapticTap();
                    setState(() => _pushNotifications = value);
                    _saveBoolSetting(_pushNotificationsKey, value);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _ToggleSettingsTile(
                  icon: Icons.alt_route_rounded,
                  title: 'Trip Alerts',
                  subtitle: 'Driver arrival and ride status updates',
                  value: _tripAlerts,
                  onChanged: (value) {
                    _hapticTap();
                    setState(() => _tripAlerts = value);
                    _saveBoolSetting(_tripAlertsKey, value);
                  },
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Preferences'),
          _animatedSection(
            child: _SettingsCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: 'Choose your preferred app language',
                  valueLabel: _selectedLanguage,
                  onTap: () {
                    _hapticTap();
                    _showSelectionSheet(
                      title: 'Language',
                      icon: Icons.language_rounded,
                      options: const ['English', 'Hindi', 'Tamil', 'Malayalam'],
                      selected: _selectedLanguage,
                      onSelected: (value) => _selectedLanguage = value,
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _SettingsTile(
                  icon: Icons.payments_outlined,
                  title: 'Payment Preferences',
                  subtitle: 'Default payment method and receipts',
                  valueLabel: _selectedPayment,
                  onTap: () {
                    _hapticTap();
                    _showSelectionSheet(
                      title: 'Payment Preferences',
                      icon: Icons.payments_outlined,
                      options: const ['UPI', 'Card', 'Cash', 'Wallet'],
                      selected: _selectedPayment,
                      onSelected: (value) => _selectedPayment = value,
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _SettingsTile(
                  icon: Icons.place_outlined,
                  title: 'Saved Places',
                  subtitle: 'Manage Home, Office and favorite spots',
                  valueLabel: '${_savedPlaces.length} places',
                  onTap: () {
                    _hapticTap();
                    _showSavedPlacesSheet();
                  },
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Privacy & Security'),
          _animatedSection(
            child: _SettingsCard(
            child: Column(
              children: [
                _ToggleSettingsTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Lock',
                  subtitle: 'Use Face ID / Fingerprint for app access',
                  value: _biometricLock,
                  onChanged: (value) {
                    _hapticTap();
                    setState(() => _biometricLock = value);
                    _saveBoolSetting(_biometricLockKey, value);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Controls',
                  subtitle: 'Manage permissions and data usage',
                  onTap: () {
                    _hapticTap();
                    _showInfoSheet(
                      title: 'Privacy Controls',
                      icon: Icons.privacy_tip_outlined,
                      description:
                          'Manage permissions like location, notifications and contacts. Detailed privacy controls will be connected to live APIs in the next step.',
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _SettingsTile(
                  icon: Icons.security_rounded,
                  title: 'Security',
                  subtitle: 'Password, login activity and devices',
                  onTap: () {
                    _hapticTap();
                    _showInfoSheet(
                      title: 'Security',
                      icon: Icons.security_rounded,
                      description:
                          'Review account protection, sign-in activity and trusted devices. Security management actions can be enabled once backend endpoints are ready.',
                    );
                  },
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 14),
          _animatedSection(
            child: _SettingsCard(
            accentColor: const Color(0xFFFFF4F4),
            accentBorderColor: const Color(0xFFFFD6D6),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out from this device',
                  destructive: true,
                  onTap: () {
                    _hapticWarning();
                    _confirmLogout();
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete Account',
                  subtitle: 'Permanently remove your account',
                  destructive: true,
                  onTap: () {
                    _hapticWarning();
                    _confirmDeleteAccount();
                  },
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF7A7A7A),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final Color? accentBorderColor;

  const _SettingsCard({
    required this.child,
    this.accentColor,
    this.accentBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: accentColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentBorderColor ?? const Color(0xFFEAECEF), width: 1),
      ),
      child: child,
    );
  }
}

class _ToggleSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF202124)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF202124),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF5F6368)),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: const Color(0xFFFE8C00),
        onChanged: onChanged,
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool destructive;
  final String? valueLabel;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.destructive = false,
    this.valueLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = destructive ? const Color(0xFFC62828) : const Color(0xFF202124);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (valueLabel != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                valueLabel!,
                style: const TextStyle(
                  color: Color(0xFF6F747B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Icon(Icons.chevron_right_rounded, color: color),
        ],
      ),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF5F6368)),
      ),
      minVerticalPadding: 6,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!.call();
            },
    );
  }
}

