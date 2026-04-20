import 'package:uuid/uuid.dart';
import 'package:gg/features/ride/domain/entities/ride.dart';

/// Mock Ride Repository
/// Simulates ride lifecycle: Pending -> Accepted -> ArrivedPickup -> Started -> Completed
class MockRideRepository {
  static const Duration _networkDelay = Duration(milliseconds: 500);

  /// Request a new ride
  Future<Ride> requestRide({
    required String userId,
    required String categoryId,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    required double estimatedFare,
  }) async {
    await Future.delayed(_networkDelay);

    return Ride(
      id: const Uuid().v4(),
      userId: userId,
      categoryId: categoryId,
      pickupLatitude: pickupLat,
      pickupLongitude: pickupLng,
      pickupAddress: pickupAddress,
      dropoffLatitude: dropoffLat,
      dropoffLongitude: dropoffLng,
      dropoffAddress: dropoffAddress,
      status: RideStatus.pending,
      estimatedFare: estimatedFare,
      requestedAt: DateTime.now(),
    );
  }

  /// Get ride details
  Future<Ride> getRideDetails(String rideId) async {
    await Future.delayed(_networkDelay);
    // Return mock ride
    throw Exception('Ride not found');
  }

  /// Cancel ride
  Future<Ride> cancelRide(String rideId) async {
    await Future.delayed(_networkDelay);
    throw Exception('Cannot cancel ride');
  }

  /// Stream ride status updates
  Stream<Ride> watchRideStatus(String rideId) async* {
    // Simulate ride lifecycle
    yield Ride(
      id: rideId,
      userId: 'mock_user',
      categoryId: 'economy',
      pickupLatitude: 40.7128,
      pickupLongitude: -74.0060,
      pickupAddress: 'Current Location',
      dropoffLatitude: 40.7580,
      dropoffLongitude: -73.9855,
      dropoffAddress: 'Destination',
      status: RideStatus.pending,
      estimatedFare: 15.50,
      requestedAt: DateTime.now(),
    );

    // Wait 3 seconds, then driver accepts
    await Future.delayed(const Duration(seconds: 3));
    yield Ride(
      id: rideId,
      userId: 'mock_user',
      driverId: const Uuid().v4(),
      categoryId: 'economy',
      pickupLatitude: 40.7128,
      pickupLongitude: -74.0060,
      pickupAddress: 'Current Location',
      dropoffLatitude: 40.7580,
      dropoffLongitude: -73.9855,
      dropoffAddress: 'Destination',
      status: RideStatus.accepted,
      estimatedFare: 15.50,
      requestedAt: DateTime.now(),
      acceptedAt: DateTime.now(),
    );

    // Wait 5 seconds, driver arrives at pickup
    await Future.delayed(const Duration(seconds: 5));
    yield Ride(
      id: rideId,
      userId: 'mock_user',
      driverId: const Uuid().v4(),
      categoryId: 'economy',
      pickupLatitude: 40.7128,
      pickupLongitude: -74.0060,
      pickupAddress: 'Current Location',
      dropoffLatitude: 40.7580,
      dropoffLongitude: -73.9855,
      dropoffAddress: 'Destination',
      status: RideStatus.arrivedPickup,
      estimatedFare: 15.50,
      requestedAt: DateTime.now(),
      acceptedAt: DateTime.now(),
    );

    // Wait 2 seconds, trip starts
    await Future.delayed(const Duration(seconds: 2));
    yield Ride(
      id: rideId,
      userId: 'mock_user',
      driverId: const Uuid().v4(),
      categoryId: 'economy',
      pickupLatitude: 40.7128,
      pickupLongitude: -74.0060,
      pickupAddress: 'Current Location',
      dropoffLatitude: 40.7580,
      dropoffLongitude: -73.9855,
      dropoffAddress: 'Destination',
      status: RideStatus.started,
      estimatedFare: 15.50,
      requestedAt: DateTime.now(),
      acceptedAt: DateTime.now(),
    );

    // Wait 8 seconds, trip completes
    await Future.delayed(const Duration(seconds: 8));
    yield Ride(
      id: rideId,
      userId: 'mock_user',
      driverId: const Uuid().v4(),
      categoryId: 'economy',
      pickupLatitude: 40.7128,
      pickupLongitude: -74.0060,
      pickupAddress: 'Current Location',
      dropoffLatitude: 40.7580,
      dropoffLongitude: -73.9855,
      dropoffAddress: 'Destination',
      status: RideStatus.completed,
      estimatedFare: 15.50,
      actualFare: 16.25,
      requestedAt: DateTime.now(),
      acceptedAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
  }

  /// Rate driver after ride completion
  Future<void> rateDriver({
    required String rideId,
    required int rating,
    required String review,
  }) async {
    await Future.delayed(_networkDelay);
  }

  /// Get ride history
  Future<List<Ride>> getRideHistory(String userId, {int limit = 20, int offset = 0}) async {
    await Future.delayed(_networkDelay);
    return [];
  }
}
