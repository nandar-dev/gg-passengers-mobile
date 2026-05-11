import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/route_names.dart';
import '../../core/session/app_session_state.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/payments/domain/use_cases/get_payment_methods_use_case.dart';
import '../../features/profile/domain/use_cases/get_passenger_profile_use_case.dart';
import '../../shared/widgets/app_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/profile_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const double _passengerRating = 4.8;
  static const String _pushNotificationsKey = 'settings.push_notifications';
  static const String _tripAlertsKey = 'settings.trip_alerts';
  static const String _biometricLockKey = 'settings.biometric_lock';
  static const String _profileNameKey = 'profile.full_name';
  static const String _profileEmailKey = 'profile.email';

  bool _pushNotifications = true;
  bool _tripAlerts = true;
  bool _biometricLock = false;
  String _selectedLanguage = 'English';
  String _selectedPayment = 'Cash';
  List<String> _paymentOptions = const ['Cash'];
  bool _isPaymentOptionsLoading = false;
  bool _isLoggingOut = false;
  String _profileName = 'John Doe';
  String _profileEmail = 'john@example.com';
  String? _profileAvatarUrl;
  bool _isProfileLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadProfileSummary();
    _loadPaymentMethodOptions(showError: false);
    getIt<ProfileNotifier>().addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    getIt<ProfileNotifier>().removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (!mounted) return;
    final notifier = getIt<ProfileNotifier>();
    setState(() {
      if (notifier.name.isNotEmpty) _profileName = notifier.name;
      if (notifier.email.isNotEmpty) _profileEmail = notifier.email;
      _profileAvatarUrl = notifier.avatarUrl;
    });
  }

  Future<void> _loadProfileSummary() async {
    try {
      final profile = await getIt<GetPassengerProfileUseCase>().call();
      if (!mounted) return;

      setState(() {
        _profileName = profile.name.trim().isEmpty ? _profileName : profile.name.trim();
        _profileEmail = profile.email.trim().isEmpty ? _profileEmail : profile.email.trim();
        _profileAvatarUrl = profile.avatarUrl;
        _isProfileLoading = false;
      });

      getIt<ProfileNotifier>().update(
        name: _profileName,
        email: _profileEmail,
        avatarUrl: profile.avatarUrl,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileNameKey, _profileName);
      await prefs.setString(_profileEmailKey, _profileEmail);
    } catch (_) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedName = prefs.getString(_profileNameKey);
      final String? cachedEmail = prefs.getString(_profileEmailKey);

      if (!mounted) return;

      setState(() {
        if (cachedName != null && cachedName.trim().isNotEmpty) {
          _profileName = cachedName.trim();
        }
        if (cachedEmail != null && cachedEmail.trim().isNotEmpty) {
          _profileEmail = cachedEmail.trim();
        }
        _isProfileLoading = false;
      });
    }
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

  Future<void> _loadPaymentMethodOptions({
    bool forceRefresh = false,
    bool showError = true,
  }) async {
    setState(() => _isPaymentOptionsLoading = true);

    try {
      final methods = await getIt<GetPaymentMethodsUseCase>().call(
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;

      final options = methods
          .map((method) => method.name.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList(growable: false);

      setState(() {
        _isPaymentOptionsLoading = false;

        if (options.isNotEmpty) {
          _paymentOptions = options;
          if (!_paymentOptions.contains(_selectedPayment)) {
            _selectedPayment = _paymentOptions.first;
          }
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _isPaymentOptionsLoading = false);
      if (showError) {
        _showMessage('Unable to load payment methods');
      }
    }
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

  void _showMessage(String message) {
    AppMessage.info(context, message);
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

  Future<void> _confirmLogout() async {
    if (_isLoggingOut) return;

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
      if (!mounted) return;
      setState(() => _isLoggingOut = true);

      try {
        await getIt<AuthRepository>().logout();
      } finally {
        if (!mounted) return;

        setState(() => _isLoggingOut = false);

        appSessionState.markForcedLogout();
        _hapticSuccess();
        _showMessage('Logged out successfully');
        context.go(RouteNames.login);
      }
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
    const Color brand = Color(0xFFFE8C00);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldPageBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppTheme.scaffoldPageBackground,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEAECEF), width: 1),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFFFE3BF),
                  child: _profileAvatarUrl != null && _profileAvatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _profileAvatarUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Icon(
                              Icons.person_rounded,
                              color: brand,
                              size: 28,
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              color: brand,
                              size: 28,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: brand,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _profileName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (_isProfileLoading)
                            const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      SizedBox(height: 3),
                      Text(
                        _profileEmail,
                        style: TextStyle(color: Color(0xFF5F6368)),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFFE8C00),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Passenger rating ${_passengerRating.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Color(0xFF202124),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                    onPressed: () => context.push(RouteNames.profileEdit),
                    icon: const Icon(Icons.edit_rounded, color: brand, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Account'),
          _SettingsCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  subtitle: 'Update name and contact info',
                  onTap: () => context.push(RouteNames.profileEdit),
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _SettingsTile(
                  icon: Icons.place_rounded,
                  title: 'Saved Places',
                  subtitle: 'Add home, work, and favorites',
                  onTap: () => context.push(RouteNames.savedPlaces),
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _SettingsTile(
                  icon: Icons.payments_outlined,
                  title: 'Payment Method',
                  subtitle: 'Default payment preference',
                  valueLabel: _isPaymentOptionsLoading ? 'Loading...' : _selectedPayment,
                  onTap: () async {
                    _hapticTap();
                    await _loadPaymentMethodOptions(showError: false);
                    if (!mounted) return;

                    if (_paymentOptions.isEmpty) {
                      _showMessage('No payment methods available right now');
                      return;
                    }

                    _showSelectionSheet(
                      title: 'Payment Preferences',
                      icon: Icons.payments_outlined,
                      options: _paymentOptions,
                      selected: _selectedPayment,
                      onSelected: (value) => _selectedPayment = value,
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: 'Choose app language',
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
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Security & Alerts'),
          _SettingsCard(
            child: Column(
              children: [
                _ToggleSettingsTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Lock',
                  subtitle: 'Use Face ID / Fingerprint',
                  value: _biometricLock,
                  onChanged: (value) {
                    _hapticTap();
                    setState(() => _biometricLock = value);
                    _saveBoolSetting(_biometricLockKey, value);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _ToggleSettingsTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Offers and app updates',
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
                  subtitle: 'Ride and driver status updates',
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
          const SizedBox(height: 14),
          const _SectionLabel('Support'),
          _SettingsCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.local_offer_outlined,
                  title: 'Promotions',
                  subtitle: 'Coupons, referral rewards and offers',
                  onTap: () => context.push(RouteNames.promotions),
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _SettingsTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Support',
                  subtitle: 'Get help with rides and account issues',
                  onTap: () => context.push(RouteNames.support),
                ),
                const Divider(height: 1, color: Color(0xFFE8EAED)),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  subtitle: 'App version, terms and privacy information',
                  onTap: () => context.push(RouteNames.about),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Account Actions'),
          _SettingsCard(
            accentColor: const Color(0xFFFFF4F4),
            accentBorderColor: const Color(0xFFFFD6D6),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out from this device',
                  destructive: true,
                  isLoading: _isLoggingOut,
                  onTap: _isLoggingOut
                      ? null
                      : () {
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
  final bool isLoading;
  final String? valueLabel;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.destructive = false,
    this.isLoading = false,
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
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
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
          if (!isLoading) Icon(Icons.chevron_right_rounded, color: color),
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

