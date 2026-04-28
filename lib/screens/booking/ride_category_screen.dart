import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';

class RideCategoryScreen extends StatefulWidget {
  const RideCategoryScreen({super.key});

  @override
  State<RideCategoryScreen> createState() => _RideCategoryScreenState();
}

class _RideCategoryScreenState extends State<RideCategoryScreen> {
  int _selectedCategoryIndex = 0;
  String _selectedPaymentMethod = 'Cash';
  IconData _selectedPaymentIcon = Icons.money;

  // Dummy coordinates representing the route
  final LatLng _pickup = const LatLng(13.736717, 100.523186);
  final LatLng _dropoff = const LatLng(13.725717, 100.511186);

  final List<Map<String, dynamic>> _categories = const [
    {
      'name': 'Economy',
      'subtitle': 'Affordable, compact rides',
      'eta': '3 min',
      'fare': 'Rs. 149',
      'icon': Icons.directions_car_filled,
    },
    {
      'name': 'Comfort',
      'subtitle': 'Newer cars with extra legroom',
      'eta': '5 min',
      'fare': 'Rs. 219',
      'icon': Icons.local_taxi_rounded,
    },
    {
      'name': 'XL',
      'subtitle': 'Spacious rides for up to 6 people',
      'eta': '7 min',
      'fare': 'Rs. 299',
      'icon': Icons.airport_shuttle_rounded,
    },
  ];

  void _showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _buildPaymentOption('Cash', Icons.money, Colors.green),
              _buildPaymentOption('Credit Card', Icons.credit_card, Colors.blue, subtitle: '**** 1234'),
              _buildPaymentOption('GG Pay', Icons.account_balance_wallet, AppTheme.primaryColor, subtitle: 'Balance: Rs. 500'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(String name, IconData icon, Color color, {String? subtitle}) {
    final bool isSelected = _selectedPaymentMethod == name;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
          : null,
      onTap: () {
        setState(() {
          _selectedPaymentMethod = name;
          _selectedPaymentIcon = icon;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Background with Route
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                (_pickup.latitude + _dropoff.latitude) / 2,
                (_pickup.longitude + _dropoff.longitude) / 2,
              ),
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gg.taxi',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      _pickup,
                      LatLng(13.731717, 100.518186), // intermediate point to simulate curve
                      _dropoff,
                    ],
                    strokeWidth: 4.5,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickup,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryDark, width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: const Center(
                        child: Icon(Icons.circle, color: AppTheme.primaryDark, size: 10),
                      ),
                    ),
                  ),
                  Marker(
                    point: _dropoff,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFE53935),
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // 2. Map Floating Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 4,
              shadowColor: Colors.black26,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.pop(),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.arrow_back, color: Colors.black87),
                ),
              ),
            ),
          ),
          
          // 3. Foreground Selection Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.25,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.45, 0.85],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Scrollable Content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Choose a ride',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Vehicles List (Scrollable)
                          ..._categories.asMap().entries.map((entry) {
                            final index = entry.key;
                            final category = entry.value;
                            final isSelected = _selectedCategoryIndex == index;
                            
                            return Padding(
                              padding: EdgeInsets.only(bottom: index < _categories.length - 1 ? 12 : 0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFFFF4E5) : Colors.white,
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/car_placeholder.png',
                                        width: 50,
                                        height: 50,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          category['icon'] as IconData,
                                          size: 40,
                                          color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  category['name'] as String,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    category['eta'] as String,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              category['subtitle'] as String,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        category['fare'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    
                    // Payment Method & Book Button Bottom Bar (Fixed)
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + safeAreaBottom),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                      ),
                      child: Row(
                        children: [
                          // Payment Method Selector
                          InkWell(
                            onTap: () => _showPaymentMethods(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(_selectedPaymentIcon, color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedPaymentMethod,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_up, size: 20, color: Colors.black54),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Action Button
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                context.go('/home/ride-tracking');
                              },
                              child: const Text(
                                'Confirm Ride',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}
