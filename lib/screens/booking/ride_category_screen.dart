import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../features/booking/domain/entities/booking_estimate.dart';
import '../../features/booking/domain/entities/booking_stop.dart';
import '../../features/booking/domain/use_cases/create_booking_use_case.dart';
import '../../features/booking/domain/use_cases/get_booking_estimate_use_case.dart';
import '../../features/booking/presentation/models/booking_args.dart';
import '../../features/payments/domain/entities/payment_method.dart';
import '../../features/payments/domain/use_cases/get_payment_methods_use_case.dart';
import '../../features/payments/presentation/payment_method_image_widget.dart';
import '../../shared/widgets/app_message.dart';

class RideCategoryScreen extends StatefulWidget {
  const RideCategoryScreen({super.key, this.args});

  final RideCategoryArgs? args;

  @override
  State<RideCategoryScreen> createState() => _RideCategoryScreenState();
}

class _RideCategoryScreenState extends State<RideCategoryScreen> {
  int _selectedCategoryIndex = 0;
  PaymentMethod? _selectedPaymentMethod;
  List<PaymentMethod> _paymentMethods = const [];
  bool _isPaymentMethodsLoading = true;
  String? _paymentMethodsError;

  BookingEstimate? _estimate;
  bool _isEstimateLoading = false;
  String? _estimateError;
  bool _isCreatingBooking = false;
  String? _bookingError;
  String _serviceId = '';
  late BookingStop _pickupStop;
  BookingStop? _waypointStop;
  late BookingStop _dropoffStop;

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

  @override
  void initState() {
    super.initState();
    _initializeStops();
    _loadPaymentMethods();
    _loadEstimate();
  }

  void _initializeStops() {
    if (widget.args != null) {
      final args = widget.args!;
      _serviceId = args.serviceId;
      _pickupStop = args.pickup;
      _waypointStop = args.waypoint;
      _dropoffStop = args.dropoff;
    } else {
      _serviceId = '';
      _pickupStop = const BookingStop(
        address: 'Pickup location',
        lat: 13.736717,
        lng: 100.523186,
        stopType: BookingStopType.pickup,
      );
      _dropoffStop = const BookingStop(
        address: 'Dropoff location',
        lat: 13.725717,
        lng: 100.511186,
        stopType: BookingStopType.dropoff,
      );
    }
  }

  List<BookingStop> get _routeStops {
    return [
      _pickupStop,
      if (_waypointStop != null) _waypointStop!,
      _dropoffStop,
    ];
  }

  VehicleEstimate? get _selectedVehicleEstimate {
    final estimate = _estimate;
    if (estimate == null || estimate.vehicles.isEmpty) return null;
    if (_selectedCategoryIndex < 0 || _selectedCategoryIndex >= estimate.vehicles.length) {
      return estimate.vehicles.first;
    }
    return estimate.vehicles[_selectedCategoryIndex];
  }

  LatLng get _mapCenter {
    final points = _routeStops.map((stop) => LatLng(stop.lat, stop.lng)).toList();
    final double latitude = points.fold<double>(0, (sum, point) => sum + point.latitude) / points.length;
    final double longitude = points.fold<double>(0, (sum, point) => sum + point.longitude) / points.length;
    return LatLng(latitude, longitude);
  }

  Future<void> _confirmRide() async {
    if (_isCreatingBooking) return;

    final selectedVehicle = _selectedVehicleEstimate;
    if (selectedVehicle == null) {
      setState(() {
        _bookingError = 'Please select a ride after the estimate loads.';
      });
      return;
    }

    setState(() {
      _isCreatingBooking = true;
      _bookingError = null;
    });

    try {
      final result = await getIt<CreateBookingUseCase>().call(
        serviceId: _serviceId,
        vehicleTypeId: selectedVehicle.vehicleTypeId,
        stops: _routeStops,
        paymentMethodId: _selectedPaymentMethod?.id,
      );

      if (!mounted) return;

      AppMessage.success(
        context,
        'Booking ${result.bookingId} created successfully.',
      );
      context.goNamed('rideTracking');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bookingError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
        });
      }
    }
  }

  Future<void> _loadPaymentMethods({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _isPaymentMethodsLoading = true;
        _paymentMethodsError = null;
      });
    }

    try {
      final methods = await getIt<GetPaymentMethodsUseCase>().call(
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;

      setState(() {
        _paymentMethods = methods;
        _isPaymentMethodsLoading = false;

        if (_paymentMethods.isEmpty) {
          _paymentMethodsError = 'No payment methods available right now.';
          _selectedPaymentMethod = null;
          return;
        }

        final selectedId = _selectedPaymentMethod?.id;
        _selectedPaymentMethod = _paymentMethods.firstWhere(
          (method) => method.id == selectedId,
          orElse: () => _paymentMethods.first,
        );
      });

      // Preload images in background (non-blocking)
      _preloadPaymentMethodImagesBackground(methods);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isPaymentMethodsLoading = false;
        _paymentMethodsError = 'Unable to load payment methods. Please try again.';
      });
    }
  }

  void _preloadPaymentMethodImagesBackground(List<PaymentMethod> methods) {
    for (final method in methods) {
      if (method.iconUrl.isNotEmpty) {
        try {
          precacheImage(
            CachedNetworkImageProvider(method.iconUrl),
            context,
          );
        } catch (_) {
          // Ignore preload errors - fallback icon will be used
        }
      }
    }
  }

  Future<void> _loadEstimate() async {
    if (_serviceId.trim().isEmpty) {
      setState(() {
        _estimateError = 'Service is missing for fare estimate.';
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isEstimateLoading = true;
        _estimateError = null;
      });
    }

    try {
      final estimate = await getIt<GetBookingEstimateUseCase>().call(
        serviceId: _serviceId,
        stops: _routeStops,
      );

      if (!mounted) return;

      setState(() {
        _estimate = estimate;
        _isEstimateLoading = false;
        if (_selectedCategoryIndex >= estimate.vehicles.length) {
          _selectedCategoryIndex = 0;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isEstimateLoading = false;
        _estimateError = 'Unable to load fare estimates right now.';
      });
    }
  }

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
              if (_isPaymentMethodsLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_paymentMethodsError != null && _paymentMethods.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      Text(
                        _paymentMethodsError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showPaymentMethods(this.context);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else
                ..._paymentMethods.map(_buildPaymentOption),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(PaymentMethod method) {
    final bool isSelected = _selectedPaymentMethod?.id == method.id;
    return ListTile(
      leading: PaymentMethodImageWidget(method: method, size: 24),
      title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
          : null,
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCategoryTile({
    required bool isSelected,
    required Widget leading,
    required String title,
    required String subtitle,
    required String etaLabel,
    required String fareLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
            leading,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          etaLabel,
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
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              fareLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimateTile({
    required VehicleEstimate vehicle,
    required int index,
    required int etaMinutes,
  }) {
    final bool isSelected = _selectedCategoryIndex == index;
    final String etaLabel = etaMinutes > 0 ? '$etaMinutes min' : '--';
    final String fareLabel = _formatFare(vehicle.estimatedFare);
    final String subtitle = vehicle.isEv
        ? '${vehicle.capacity} seats • EV'
        : '${vehicle.capacity} seats';

    final IconData icon = vehicle.isEv
        ? Icons.electric_car_rounded
        : Icons.directions_car_filled;

    return _buildCategoryTile(
      isSelected: isSelected,
      leading: Icon(
        icon,
        size: 40,
        color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
      ),
      title: vehicle.nameEn,
      subtitle: subtitle,
      etaLabel: etaLabel,
      fareLabel: fareLabel,
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
    );
  }

  Widget _buildFallbackTile({
    required Map<String, dynamic> category,
    required int index,
  }) {
    final bool isSelected = _selectedCategoryIndex == index;
    return _buildCategoryTile(
      isSelected: isSelected,
      leading: Image.asset(
        'assets/icons/car_placeholder.png',
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) => Icon(
          category['icon'] as IconData,
          size: 40,
          color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
        ),
      ),
      title: category['name'] as String,
      subtitle: category['subtitle'] as String,
      etaLabel: category['eta'] as String,
      fareLabel: category['fare'] as String,
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
    );
  }

  String _formatFare(double value) {
    final rounded = value.round();
    return 'Ks. $rounded';
  }

  List<LatLng> _routePoints() {
    return _routeStops.map((stop) => LatLng(stop.lat, stop.lng)).toList();
  }

  Widget _buildRouteMarker(BookingStop stop) {
    switch (stop.stopType) {
      case BookingStopType.pickup:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryDark, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: const Center(
            child: Icon(Icons.circle, color: AppTheme.primaryDark, size: 10),
          ),
        );
      case BookingStopType.waypoint:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: const Center(
            child: Icon(Icons.stop_circle, color: AppTheme.primaryColor, size: 12),
          ),
        );
      case BookingStopType.dropoff:
        return const Icon(
          Icons.location_on,
          color: Color(0xFFE53935),
          size: 36,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final estimate = _estimate;
    final bool hasEstimate = estimate != null && estimate.vehicles.isNotEmpty;
    final int etaMinutes = estimate == null
        ? 0
        : (estimate.durationSeconds / 60).round();
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Background with Route
          FlutterMap(
            options: MapOptions(
              initialCenter: _mapCenter,
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
                    points: _routePoints(),
                    strokeWidth: 4.5,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
              MarkerLayer(
                markers: _routeStops
                    .map(
                      (stop) => Marker(
                        point: LatLng(stop.lat, stop.lng),
                        width: 40,
                        height: 40,
                        child: _buildRouteMarker(stop),
                      ),
                    )
                    .toList(growable: false),
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
                          if (_bookingError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _bookingError!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          if (_isEstimateLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_estimateError != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                _estimateError!,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            )
                          else if (hasEstimate)
                            ...estimate.vehicles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final vehicle = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index < estimate.vehicles.length - 1 ? 12 : 0,
                                ),
                                child: _buildEstimateTile(
                                  vehicle: vehicle,
                                  index: index,
                                  etaMinutes: etaMinutes,
                                ),
                              );
                            })
                          else
                            ..._categories.asMap().entries.map((entry) {
                              final index = entry.key;
                              final category = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index < _categories.length - 1 ? 12 : 0,
                                ),
                                child: _buildFallbackTile(
                                  category: category,
                                  index: index,
                                ),
                              );
                            }),
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
                            onTap: _isPaymentMethodsLoading
                                ? null
                                : () => _showPaymentMethods(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  if (_isPaymentMethodsLoading)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else if (_selectedPaymentMethod != null)
                                    PaymentMethodImageWidget(
                                      method: _selectedPaymentMethod!,
                                      size: 18,
                                      showBackground: false,
                                    )
                                  else
                                    const Icon(Icons.payments_rounded, color: Colors.black54, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isPaymentMethodsLoading
                                        ? 'Loading...'
                                        : (_selectedPaymentMethod?.name ?? 'Select payment'),
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
                              onPressed: _isCreatingBooking ? null : _confirmRide,
                              child: _isCreatingBooking
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _selectedVehicleEstimate == null
                                          ? 'Select a ride'
                                          : 'Confirm Ride',
                                      style: const TextStyle(
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
