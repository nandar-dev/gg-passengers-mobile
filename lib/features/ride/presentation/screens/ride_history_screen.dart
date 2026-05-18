import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/app_message.dart';
import '../../../../features/booking/domain/entities/active_booking_stop.dart';
import '../../../../features/booking/domain/entities/booking_stop.dart';
import '../../../../features/booking/domain/entities/active_booking.dart';
import '../../../../features/booking/domain/repositories/booking_repository.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../models/ride_tracking_args.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<ActiveBooking> _bookings = const [];
  String? _trackingBookingId;

  @override
  void initState() {
    super.initState();
    _loadActiveBookings();
  }

  Future<void> _loadActiveBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await getIt<BookingRepository>().getActiveBookings();
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Unable to load active bookings. Please try again.';
      });
    }
  }

  String _fareLabel(double fare) {
    if (fare <= 0) return '-';
    return fare.toStringAsFixed(2);
  }

  String _statusLabel(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return 'UNKNOWN';
    return value.replaceAll('_', ' ').toUpperCase();
  }

  BookingStop _toBookingStop(
    ActiveBookingStop stop, {
    required BookingStopType fallbackType,
    required double fallbackLat,
    required double fallbackLng,
  }) {
    return BookingStop(
      address: stop.address.trim().isEmpty ? 'Unknown address' : stop.address,
      lat: stop.lat ?? fallbackLat,
      lng: stop.lng ?? fallbackLng,
      stopType: stop.stopType == BookingStopType.pickup ||
              stop.stopType == BookingStopType.waypoint ||
              stop.stopType == BookingStopType.dropoff
          ? stop.stopType
          : fallbackType,
    );
  }

  double _firstNonNullLat(List<ActiveBookingStop> stops) {
    for (final stop in stops) {
      if (stop.lat != null) return stop.lat!;
    }
    return 0;
  }

  double _firstNonNullLng(List<ActiveBookingStop> stops) {
    for (final stop in stops) {
      if (stop.lng != null) return stop.lng!;
    }
    return 0;
  }

  RideTrackingArgs _buildTrackingArgs(ActiveBooking booking) {
    final pickupStop = booking.stops.where((stop) => stop.stopType == BookingStopType.pickup).toList();
    final waypointStop = booking.stops.where((stop) => stop.stopType == BookingStopType.waypoint).toList();
    final dropoffStop = booking.stops.where((stop) => stop.stopType == BookingStopType.dropoff).toList();

    final pickupLat = _firstNonNullLat(pickupStop.isNotEmpty ? pickupStop : booking.stops);
    final pickupLng = _firstNonNullLng(pickupStop.isNotEmpty ? pickupStop : booking.stops);
    final dropoffLat = _firstNonNullLat(dropoffStop.isNotEmpty ? dropoffStop : booking.stops);
    final dropoffLng = _firstNonNullLng(dropoffStop.isNotEmpty ? dropoffStop : booking.stops);

    final pickup = pickupStop.isNotEmpty
        ? _toBookingStop(
            pickupStop.first,
            fallbackType: BookingStopType.pickup,
            fallbackLat: pickupLat,
            fallbackLng: pickupLng,
          )
        : BookingStop(
            address: booking.pickupAddress,
            lat: pickupLat,
            lng: pickupLng,
            stopType: BookingStopType.pickup,
          );

    final waypoint = waypointStop.isNotEmpty
        ? _toBookingStop(
            waypointStop.first,
            fallbackType: BookingStopType.waypoint,
            fallbackLat: (pickupLat + dropoffLat) / 2,
            fallbackLng: (pickupLng + dropoffLng) / 2,
          )
        : null;

    final dropoff = dropoffStop.isNotEmpty
        ? _toBookingStop(
            dropoffStop.first,
            fallbackType: BookingStopType.dropoff,
            fallbackLat: dropoffLat,
            fallbackLng: dropoffLng,
          )
        : BookingStop(
            address: booking.dropoffAddress,
            lat: dropoffLat,
            lng: dropoffLng,
            stopType: BookingStopType.dropoff,
          );

    return RideTrackingArgs(
      bookingId: booking.id,
      bookingCode: booking.bookingId,
      status: booking.status,
      serviceId: booking.serviceId,
      pickup: pickup,
      waypoint: waypoint,
      dropoff: dropoff,
    );
  }

  Future<void> _continueTracking(ActiveBooking booking) async {
    if (_trackingBookingId != null) return;

    setState(() {
      _trackingBookingId = booking.id;
    });

    try {
      final detail = await getIt<BookingRepository>().getActiveBookingById(
        bookingId: booking.id,
      );

      if (!mounted) return;
      context.goNamed(
        'rideTracking',
        extra: _buildTrackingArgs(detail),
      );
    } catch (_) {
      if (!mounted) return;
      AppMessage.error(
        context,
        'Unable to open live tracking for this booking.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _trackingBookingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride History')),
      body: RefreshIndicator(
        onRefresh: _loadActiveBookings,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SkeletonList(itemCount: 4),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFB3261E)),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B6F76)),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Retry',
            onPressed: _loadActiveBookings,
          ),
        ],
      );
    }

    if (_bookings.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 56),
          Icon(Icons.receipt_long_outlined, size: 52, color: Color(0xFF9EA3AA)),
          SizedBox(height: 12),
          Text(
            'No active bookings right now.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Color(0xFF6B6F76)),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE9EBEF)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.bookingId,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE8C00).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(booking.status),
                        style: const TextStyle(
                          color: Color(0xFF9C4F00),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fare: ${_fareLabel(booking.estimatedFare)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A3D42),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pickup: ${booking.pickupAddress}',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF5A5E66)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dropoff: ${booking.dropoffAddress}',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF5A5E66)),
                ),
                if (booking.stops.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: booking.stops
                        .map(
                          (stop) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F7F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Text(
                              '${stop.stopType.name.toUpperCase()} - ${stop.status.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF62676F),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
                const SizedBox(height: 12),
                SecondaryButton(
                  label: _trackingBookingId == booking.id
                      ? 'Opening...'
                      : 'Continue Tracking',
                  onPressed: _trackingBookingId == null
                      ? () => _continueTracking(booking)
                      : null,
                  height: 44,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
