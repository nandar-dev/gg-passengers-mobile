import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/booking/domain/entities/booking_stop.dart';
import '../../../../features/booking/domain/entities/nearby_driver.dart';
import '../../../../features/booking/domain/repositories/booking_repository.dart';
import '../../../../shared/widgets/app_message.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/primary_text_field.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../models/ride_tracking_args.dart';

class RideTrackingScreen extends StatefulWidget {
  const RideTrackingScreen({super.key, this.args});

  final RideTrackingArgs? args;

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  static const Duration _liveRefreshInterval = Duration(seconds: 8);

  late BookingStop _pickup;
  late BookingStop _dropoff;
  BookingStop? _waypoint;

  String _bookingId = '';
  String _bookingCode = '-';
  String _status = 'pending';
  String _serviceId = '';

  bool _isLoadingNearbyDrivers = false;
  bool _isCancellingRide = false;
  String? _nearbyError;
  List<NearbyDriver> _nearbyDrivers = const [];
  Timer? _pollingTimer;
  bool _isPollingInProgress = false;
  bool _hasHandledTerminalStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeFromArgs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleTerminalStatus();
    });

    _refreshLiveData(showNearbyLoading: true);
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_liveRefreshInterval, (_) {
      if (!mounted || _isCancellingRide || _status == 'cancelled' || _status == 'completed') {
        return;
      }
      _refreshLiveData();
    });
  }

  void _handleTerminalStatus() {
    if (!mounted || _hasHandledTerminalStatus) {
      return;
    }

    if (_status == 'completed') {
      _hasHandledTerminalStatus = true;
      AppMessage.info(context, 'Ride completed. Please submit your review.');
      context.goNamed('rideReview', extra: _bookingId);
      return;
    }

    if (_status == 'cancelled') {
      _hasHandledTerminalStatus = true;
      AppMessage.info(context, 'This booking has been cancelled.');
      context.go(RouteNames.home);
    }
  }

  Future<void> _refreshLiveData({bool showNearbyLoading = false}) async {
    if (_isPollingInProgress) return;
    _isPollingInProgress = true;

    await Future.wait([
      _loadNearbyDrivers(showLoading: showNearbyLoading),
      _loadBookingStatus(),
    ]);

    _isPollingInProgress = false;
  }

  void _initializeFromArgs() {
    final args = widget.args;
    if (args == null) {
      _pickup = const BookingStop(
        address: 'Pickup location',
        lat: 13.736717,
        lng: 100.523186,
        stopType: BookingStopType.pickup,
      );
      _dropoff = const BookingStop(
        address: 'Dropoff location',
        lat: 13.725717,
        lng: 100.511186,
        stopType: BookingStopType.dropoff,
      );
      _bookingCode = '-';
      _bookingId = '';
      _status = 'pending';
      _serviceId = '';
      return;
    }

    _pickup = args.pickup;
    _waypoint = args.waypoint;
    _dropoff = args.dropoff;
    _bookingCode = args.bookingCode;
    _bookingId = args.bookingId;
    _status = args.status.trim().toLowerCase().isEmpty
        ? 'pending'
        : args.status.trim().toLowerCase();
    _serviceId = args.serviceId;
  }

  Future<void> _loadNearbyDrivers({bool showLoading = false}) async {
    if (_serviceId.trim().isEmpty) {
      setState(() {
        _nearbyError = 'Service is missing. Unable to load nearby drivers.';
      });
      return;
    }

    if (showLoading && mounted) {
      setState(() {
        _isLoadingNearbyDrivers = true;
        _nearbyError = null;
      });
    }

    try {
      final drivers = await getIt<BookingRepository>().getNearbyDrivers(
        lat: _pickup.lat,
        lng: _pickup.lng,
        serviceId: _serviceId,
        radiusKm: 50,
      );

      if (!mounted) return;
      setState(() {
        _nearbyDrivers = drivers;
        _isLoadingNearbyDrivers = false;
        _nearbyError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingNearbyDrivers = false;
        _nearbyError = 'Unable to fetch nearby drivers right now.';
      });
    }
  }

  Future<void> _loadBookingStatus() async {
    if (_bookingId.trim().isEmpty) {
      return;
    }

    try {
      final latestStatus = await getIt<BookingRepository>().getBookingStatus(
        bookingId: _bookingId,
      );

      if (!mounted) return;

      if (_status != latestStatus) {
        setState(() {
          _status = latestStatus;
        });
      }

      _handleTerminalStatus();
    } catch (_) {
      // Keep current status when polling fails.
    }
  }

  LatLng get _driverLocation {
    if (_nearbyDrivers.isNotEmpty) {
      final first = _nearbyDrivers.first;
      return LatLng(first.lat, first.lng);
    }

    return LatLng(
      (_pickup.lat + _dropoff.lat) / 2,
      (_pickup.lng + _dropoff.lng) / 2,
    );
  }

  NearbyDriver? get _leadDriver {
    if (_nearbyDrivers.isEmpty) return null;
    return _nearbyDrivers.first;
  }

  String get _statusLabel {
    switch (_status) {
      case 'pending':
        return 'FINDING DRIVER';
      case 'accepted':
        return 'ON THE WAY';
      case 'arrived_pickup':
      case 'arrivedpickup':
        return 'AT PICKUP';
      case 'started':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return _status.toUpperCase();
    }
  }

  String get _etaLine {
    final driver = _leadDriver;
    if (_status == 'cancelled') {
      return 'This booking has been cancelled.';
    }
    if (driver?.etaMinutes != null) {
      return 'Arriving in ${driver!.etaMinutes} min';
    }
    return 'Looking for the nearest available driver';
  }

  String get _distanceLine {
    final driver = _leadDriver;
    if (driver?.distanceKm != null) {
      return 'Driver is ${driver!.distanceKm!.toStringAsFixed(1)} km away';
    }
    return 'Live nearby drivers: ${_nearbyDrivers.length}';
  }

  Future<void> _openCancelRideSheet() async {
    if (_bookingId.trim().isEmpty) {
      AppMessage.error(context, 'Booking id is missing.');
      return;
    }

    final reasonController = TextEditingController();
    String? reasonError;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cancel booking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please tell us why you want to cancel this ride.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  PrimaryTextField(
                    label: 'Reason',
                    hint: 'Enter cancellation reason',
                    controller: reasonController,
                    errorText: reasonError,
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    label: 'Keep Booking',
                    onPressed: _isCancellingRide ? null : () => context.pop(),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'Confirm Cancellation',
                    isLoading: _isCancellingRide,
                    onPressed: _isCancellingRide
                        ? null
                        : () async {
                            final reason = reasonController.text.trim();
                            if (reason.isEmpty) {
                              setModalState(() {
                                reasonError = 'Reason is required.';
                              });
                              return;
                            }

                            setModalState(() {
                              reasonError = null;
                            });

                            setState(() {
                              _isCancellingRide = true;
                            });

                            try {
                              await getIt<BookingRepository>().cancelBooking(
                                bookingId: _bookingId,
                                reason: reason,
                              );

                              if (!mounted) return;
                              setState(() {
                                _status = 'cancelled';
                              });
                              if (context.mounted) context.pop();
                              AppMessage.success(
                                this.context,
                                'Booking cancelled successfully.',
                              );
                              _hasHandledTerminalStatus = true;
                              this.context.go(RouteNames.home);
                            } catch (_) {
                              if (!mounted) return;
                              AppMessage.error(
                                this.context,
                                'Unable to cancel booking right now.',
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isCancellingRide = false;
                                });
                              }
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    reasonController.dispose();
  }

  Color _statusColor() {
    if (_status == 'cancelled') return Colors.red;
    if (_status == 'completed') return Colors.green;
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leadDriver = _leadDriver;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _driverLocation,
              initialZoom: 14.2,
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
                      LatLng(_pickup.lat, _pickup.lng),
                      if (_waypoint != null) LatLng(_waypoint!.lat, _waypoint!.lng),
                      LatLng(_dropoff.lat, _dropoff.lng),
                    ],
                    strokeWidth: 4.5,
                    color: AppTheme.primaryColor.withValues(alpha: 0.75),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(_pickup.lat, _pickup.lng),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.radio_button_checked,
                      color: AppTheme.primaryColor,
                      size: 26,
                    ),
                  ),
                  Marker(
                    point: LatLng(_dropoff.lat, _dropoff.lng),
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 34,
                    ),
                  ),
                  ..._nearbyDrivers.take(3).map(
                        (driver) => Marker(
                          point: LatLng(driver.lat, driver.lng),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_car_filled,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _buildFloatingButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                _buildStatusBadge(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Booking ${_bookingCode.trim().isEmpty ? '-' : _bookingCode}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _statusColor().withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _statusLabel,
                          style: TextStyle(
                            color: _statusColor(),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _etaLine,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _distanceLine,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (_nearbyError != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _nearbyError!,
                        style: const TextStyle(
                          color: Color(0xFFB3261E),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFFE0E0E0),
                          child: Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                leadDriver?.name ?? 'Searching driver...',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                leadDriver?.vehicleNumber.isNotEmpty == true
                                    ? leadDriver!.vehicleNumber
                                    : 'Nearby drivers: ${_nearbyDrivers.length}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isLoadingNearbyDrivers)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: _status == 'cancelled' ? 'Ride Cancelled' : 'Complete Ride',
                    onPressed: _status == 'cancelled'
                        ? null
                        : () => context.goNamed(
                              'rideReview',
                              extra: _bookingId,
                            ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Refresh Drivers',
                          onPressed: _isLoadingNearbyDrivers
                              ? null
                              : () => _refreshLiveData(showNearbyLoading: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SecondaryButton(
                          label: 'Cancel Ride',
                          onPressed: (_status == 'cancelled' || _isCancellingRide)
                              ? null
                              : _openCancelRideSheet,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.black, size: 20),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _statusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _statusLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
