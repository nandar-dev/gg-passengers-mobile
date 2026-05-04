import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/services/domain/entities/service_entity.dart';
import '../../features/services/domain/use_cases/get_services_use_case.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../features/booking/presentation/models/booking_args.dart';
import '../profile/settings_screen.dart';
import '../../shared/widgets/app_message.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';

enum _LocationChoice { allowed, maybeLater }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _locationChoiceKey = 'home.location_choice';
  static const String _choiceAllowed = 'allowed';
  static const String _choiceMaybeLater = 'maybe_later';
  static const String _profileNameKey = 'profile.full_name';

  int _currentIndex = 0;
  List<AppService> _services = [];
  bool _isLoadingServices = true;
  bool _didScheduleInitialPrompt = false;
  bool _isLocationChoiceLoaded = false;
  bool _hasShownInitialPrompt = false;
  bool _isLocationPromptOpen = false;
  String? _savedLocationChoice;
  String _locationStatusLabel = 'Checking location...';
  String _passengerName = 'there';
  String _greeting = 'Good day';

  @override
  void initState() {
    super.initState();
    _loadSavedLocationChoice();
    _refreshLocationStatus();
    _loadServices();
    _loadProfileName();
    _updateGreeting();
  }

  Future<void> _loadServices() async {
    try {
      final services = await getIt<GetServicesUseCase>().call();
      if (!mounted) return;
      setState(() {
        _services = services;
        _isLoadingServices = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingServices = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didScheduleInitialPrompt) return;
    _didScheduleInitialPrompt = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitialLocationPromptIfNeeded();
    });
  }

  Future<void> _loadSavedLocationChoice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedChoice = prefs.getString(_locationChoiceKey);
    if (!mounted) return;

    setState(() {
      _savedLocationChoice = savedChoice;
      _isLocationChoiceLoaded = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitialLocationPromptIfNeeded();
    });
  }

  Future<void> _loadProfileName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString(_profileNameKey);
    if (!mounted) return;
    setState(() {
      _passengerName = (name == null || name.trim().isEmpty)
          ? 'there'
          : name.trim();
    });
  }

  void _updateGreeting() {
    final int hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    _greeting = greeting;
  }

  Future<void> _refreshLocationStatus() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final LocationPermission permission = await Geolocator.checkPermission();

    String status;
    if (!serviceEnabled) {
      status = 'Location: Service Off';
    } else if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      status = 'Location: Allowed';
    } else if (permission == LocationPermission.deniedForever) {
      status = 'Location: Denied Forever';
    } else {
      status = 'Location: Denied';
    }

    if (!mounted) return;
    setState(() {
      _locationStatusLabel = status;
    });
  }

  Future<void> _saveLocationChoice(String choice) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationChoiceKey, choice);
    if (!mounted) return;
    setState(() {
      _savedLocationChoice = choice;
    });
  }

  Future<void> _showInitialLocationPromptIfNeeded() async {
    if (!mounted) return;
    if (!_isLocationChoiceLoaded || _hasShownInitialPrompt) return;
    if (_savedLocationChoice == _choiceMaybeLater ||
        _savedLocationChoice == _choiceAllowed) {
      return;
    }
    _hasShownInitialPrompt = true;
    final _LocationChoice? choice = await _showLocationPrompt();
    if (!mounted || choice == null) return;

    if (choice == _LocationChoice.allowed) {
      await _requestLocationPermission();
      return;
    }

    await _saveLocationChoice(_choiceMaybeLater);
    await _refreshLocationStatus();
  }

  Future<_LocationChoice?> _showLocationPrompt() async {
    if (!mounted) return null;
    if (_isLocationPromptOpen) return null;

    _isLocationPromptOpen = true;

    try {
      return await showModalBottomSheet<_LocationChoice>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enable your location',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Location helps us find nearby rides and accurate pickup points.',
                  style: TextStyle(color: Color(0xFF5F6368)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Allow Location Access',
                    onPressed: () =>
                        Navigator.of(context).pop(_LocationChoice.allowed),
                  ),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Maybe Later',
                  onPressed: () =>
                      Navigator.of(context).pop(_LocationChoice.maybeLater),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      _isLocationPromptOpen = false;
    }
  }

  Future<bool> _requestLocationPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _refreshLocationStatus();
      if (mounted) {
        AppMessage.info(context, 'Please enable location services to continue');
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final bool granted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (granted) {
      await _saveLocationChoice(_choiceAllowed);
      await _refreshLocationStatus();
      return true;
    }

    if (mounted && permission == LocationPermission.deniedForever) {
      AppMessage.error(
        context,
        'Location permission is permanently denied. Please allow it in Settings.',
      );
    }

    await _refreshLocationStatus();

    return false;
  }

  Future<bool> _ensureLocationAccess() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    final bool alreadyGranted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    if (alreadyGranted) {
      await _saveLocationChoice(_choiceAllowed);
      await _refreshLocationStatus();
      // _syncLocationToMapIfAllowed();
      return true;
    }

    final _LocationChoice? choice = await _showLocationPrompt();
    if (choice == _LocationChoice.maybeLater) {
      await _saveLocationChoice(_choiceMaybeLater);
      await _refreshLocationStatus();
      return false;
    }

    if (choice == _LocationChoice.allowed) {
      return _requestLocationPermission();
    }

    return false;
  }

  Future<void> _onWhereToTap() async {
    final bool hasAccess = await _ensureLocationAccess();
    if (!mounted) return;
    if (!hasAccess) return;
    final String? serviceId = _resolveDefaultServiceId();
    context.pushNamed(
      'searchLocation',
      extra: SearchLocationArgs(serviceId: serviceId ?? ''),
    );
  }

  String? _resolveDefaultServiceId() {
    if (_services.isEmpty) return null;
    final taxi = _services.firstWhere(
      (service) => service.nameEn.toLowerCase().contains('taxi'),
      orElse: () => _services.first,
    );
    return taxi.id;
  }

  void _onServiceTap(AppService service) {
    context.pushNamed(
      'searchLocation',
      extra: SearchLocationArgs(serviceId: service.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _HomeTab(
        onWhereToTap: _onWhereToTap,
        onServiceTap: _onServiceTap,
        locationStatusLabel: _locationStatusLabel,
        passengerName: _passengerName,
        greeting: _greeting,
        services: _services,
        isLoadingServices: _isLoadingServices,
      ),
      const _RidesTab(),
      const _AccountTab(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffoldPageBackground,
      body: SafeArea(child: tabs[_currentIndex]),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final VoidCallback onWhereToTap;
  final void Function(AppService service) onServiceTap;
  final String locationStatusLabel;
  final String passengerName;
  final String greeting;
  final List<AppService> services;
  final bool isLoadingServices;

  const _HomeTab({
    required this.onWhereToTap,
    required this.onServiceTap,
    required this.locationStatusLabel,
    required this.passengerName,
    required this.greeting,
    required this.services,
    required this.isLoadingServices,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  Widget build(BuildContext context) {
    const List<String> rideTypes = ['Car', 'Bike', 'Schedule', 'Carrier Send'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.greeting}, ${widget.passengerName}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1DF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD6A6)),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFFFE8C00)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Where are you going?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Best routes and trusted drivers, in minutes.',
          style: TextStyle(fontSize: 12, color: Color(0xFF7A8087)),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.white,
          elevation: 4,
          shadowColor: const Color(0x22000000),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onWhereToTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: const [
                  Icon(
                    Icons.search_rounded,
                    color: Color(0xFF202124),
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Where to?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF202124),
                      ),
                    ),
                  ),
                  Icon(Icons.tune_rounded, color: Color(0xFF8A8D91), size: 20),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        _buildSectionDivider(),
        const SizedBox(height: 18),
        const Text(
          'Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (widget.isLoadingServices && widget.services.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.services.isNotEmpty
                  ? widget.services.length
                  : rideTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final bool hasServices = widget.services.isNotEmpty;
                final AppService? service = hasServices
                    ? widget.services[index]
                    : null;
                final String label = hasServices
                    ? service!.nameEn
                    : rideTypes[index];
                final IconData icon = _getServiceIcon(label);

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  elevation: 2,
                  shadowColor: const Color(0x14000000),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: service == null ? null : () => widget.onServiceTap(service),
                    child: SizedBox(
                      width: 86,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E2),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFFFD9AA)),
                            ),
                            child: Icon(
                              icon,
                              color: const Color(0xFFFE8C00),
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        _buildSectionDivider(),
        const SizedBox(height: 18),
        const Text(
          'Saved Places',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        _buildSavedPlaceTile(Icons.home_rounded, 'Home', 'MG Road, Bangalore'),
        _buildSavedPlaceTile(
          Icons.work_rounded,
          'Office',
          'Manyata Tech Park, Bangalore',
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSavedPlaceTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: const Icon(Icons.navigate_next, color: Colors.grey),
    );
  }

  Widget _buildSectionDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  IconData _getServiceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'car':
      case 'taxi':
        return Icons.directions_car_rounded;
      case 'bike':
        return Icons.two_wheeler_rounded;
      case 'delivery':
        return Icons.local_shipping_rounded;
      case 'schedule':
        return Icons.calendar_month_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }
}

class _RidesTab extends StatefulWidget {
  const _RidesTab();

  @override
  State<_RidesTab> createState() => _RidesTabState();
}

class _RidesTabState extends State<_RidesTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          'My Rides',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFE8C00),
          indicatorColor: const Color(0xFFFE8C00),
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Upcoming'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _RideMonthSection(
                monthTitle: 'March 2026',
                rides: [
                  'Airport to MG Road • 14 Mar',
                  'Tech Park to Home • 09 Mar',
                  'Koramangala to Indiranagar • 03 Mar',
                ],
              ),
              _RideMonthSection(
                monthTitle: 'April 2026',
                rides: [
                  'Scheduled: Home to Airport • 22 Apr',
                  'Scheduled: Office to Whitefield • 28 Apr',
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RideMonthSection extends StatelessWidget {
  final String monthTitle;
  final List<String> rides;

  const _RideMonthSection({required this.monthTitle, required this.rides});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rides.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              monthTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          );
        }
        final ride = rides[index - 1];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFF3E2),
              child: Icon(Icons.local_taxi_rounded, color: Color(0xFFFE8C00)),
            ),
            title: Text(ride),
            subtitle: const Text('Completed • Fare: Rs. 199'),
          ),
        );
      },
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}
