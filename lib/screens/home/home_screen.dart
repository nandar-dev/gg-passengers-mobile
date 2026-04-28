import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  int _currentIndex = 0;
  bool _didScheduleInitialPrompt = false;
  bool _isLocationChoiceLoaded = false;
  bool _hasShownInitialPrompt = false;
  bool _isLocationPromptOpen = false;
  LatLng _mapCenter = const LatLng(12.9716, 77.5946);
  String? _savedLocationChoice;
  String _locationStatusLabel = 'Checking location...';

  @override
  void initState() {
    super.initState();
    _loadSavedLocationChoice();
    _refreshLocationStatus();
    _syncLocationToMapIfAllowed();
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

  Future<void> _syncLocationToMapIfAllowed() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    final bool isGranted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    if (!isGranted) return;

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;
    setState(() {
      _mapCenter = LatLng(position.latitude, position.longitude);
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
      _syncLocationToMapIfAllowed();
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
      _syncLocationToMapIfAllowed();
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

    if (hasAccess) {
      // Do not await the map sync to avoid delaying the navigation
      _syncLocationToMapIfAllowed();
    }

    context.pushNamed('searchLocation');
  }

  Future<void> _onRecenterTap() async {
    final bool hasAccess = await _ensureLocationAccess();
    if (!hasAccess || !mounted) return;

    await _syncLocationToMapIfAllowed();
    if (!mounted) return;
    AppMessage.success(context, 'Map centered to your current location');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _HomeTab(
        onWhereToTap: _onWhereToTap,
        onRecenterTap: _onRecenterTap,
        locationStatusLabel: _locationStatusLabel,
        mapCenter: _mapCenter,
      ),
      const _RidesTab(),
      const _AccountTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(child: tabs[_currentIndex]),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onWhereToTap;
  final VoidCallback onRecenterTap;
  final String locationStatusLabel;
  final LatLng mapCenter;

  const _HomeTab({
    required this.onWhereToTap,
    required this.onRecenterTap,
    required this.locationStatusLabel,
    required this.mapCenter,
  });

  @override
  Widget build(BuildContext context) {
    const List<String> offers = [
      'Flat 30% off on first 3 rides',
      'Weekend bike rides from Rs. 49',
      'Schedule rides and save up to 20%',
    ];

    const List<String> rideTypes = ['Car', 'Bike', 'Schedule', 'Carrier Send'];

    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            key: ValueKey<String>(
              'map-${mapCenter.latitude.toStringAsFixed(5)}-${mapCenter.longitude.toStringAsFixed(5)}',
            ),
            options: MapOptions(initialCenter: mapCenter, initialZoom: 13.4),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gg.taxi',
              ),
              const MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(12.9688, 77.6010),
                    width: 36,
                    height: 36,
                    child: _MapVehicle(icon: Icons.directions_car_rounded),
                  ),
                  Marker(
                    point: LatLng(12.9752, 77.5886),
                    width: 36,
                    height: 36,
                    child: _MapVehicle(icon: Icons.two_wheeler_rounded),
                  ),
                  Marker(
                    point: LatLng(12.9802, 77.5951),
                    width: 36,
                    height: 36,
                    child: _MapVehicle(icon: Icons.directions_car_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onRecenterTap,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF202124),
                ),
              ),
            ),
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.33,
          minChildSize: 0.22,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: const [0.33, 0.95],
          builder: (context, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 18,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                children: [
                  const Center(
                    child: SizedBox(
                      width: 44,
                      child: Divider(thickness: 4, color: Color(0xFFD7D7D7)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Offers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: offers.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 10),
                      itemBuilder: (_, index) => Container(
                        width: 250,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFBD59), Color(0xFFFE8C00)],
                          ),
                        ),
                        child: Text(
                          offers[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ride Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: rideTypes
                        .map(
                          (type) => Chip(
                            label: Text(type),
                            backgroundColor: const Color(0xFFFFF3E2),
                            side: const BorderSide(color: Color(0xFFFFD9AA)),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onWhereToTap,
                    child: const AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Where to',
                          prefixIcon: Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: Color(0xFFFAFAFA),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Saved Addresses',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.home_rounded),
                    title: Text('Home'),
                    subtitle: Text('MG Road, Bangalore'),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.work_rounded),
                    title: Text('Office'),
                    subtitle: Text('Manyata Tech Park, Bangalore'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
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

class _MapVehicle extends StatelessWidget {
  final IconData icon;

  const _MapVehicle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: const Color(0xFFFE8C00)),
    );
  }
}
