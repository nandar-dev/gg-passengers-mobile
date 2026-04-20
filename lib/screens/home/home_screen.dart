import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../profile/settings_screen.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _hasAskedLocation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasAskedLocation) return;
    _hasAskedLocation = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLocationPrompt();
    });
  }

  Future<void> _showLocationPrompt() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
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
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Geolocator.requestPermission();
                  },
                ),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Maybe Later',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<Widget> tabs = [_HomeTab(), _RidesTab(), _AccountTab()];

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
  const _HomeTab();

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
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD7E9FF), Color(0xFFE9F7E9)],
              ),
            ),
            child: Stack(
              children: const [
                Positioned(
                  top: 120,
                  left: 30,
                  child: _MapVehicle(icon: Icons.directions_car_rounded),
                ),
                Positioned(
                  top: 180,
                  right: 40,
                  child: _MapVehicle(icon: Icons.two_wheeler_rounded),
                ),
                Positioned(
                  bottom: 260,
                  left: 70,
                  child: _MapVehicle(icon: Icons.directions_car_rounded),
                ),
                Positioned(
                  bottom: 320,
                  right: 80,
                  child: _MapVehicle(icon: Icons.two_wheeler_rounded),
                ),
              ],
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
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: offers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'Where to',
                      prefixIcon: Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Color(0xFFFAFAFA),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
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
