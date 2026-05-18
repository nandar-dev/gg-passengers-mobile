import 'package:injectable/injectable.dart';

import '../../domain/entities/active_booking.dart';
import '../../domain/entities/booking_creation_result.dart';
import '../../domain/entities/booking_estimate.dart';
import '../../domain/entities/nearby_driver.dart';
import '../../domain/entities/booking_stop.dart';
import '../../domain/repositories/booking_repository.dart';
import '../data_sources/booking_remote_data_source.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  BookingRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ActiveBooking>> getActiveBookings() async {
    final models = await _remoteDataSource.fetchActiveBookings();
    return models.map((model) => model.toDomain()).toList(growable: false);
  }

  @override
  Future<ActiveBooking> getActiveBookingById({
    required String bookingId,
  }) async {
    final model = await _remoteDataSource.fetchActiveBookingById(
      bookingId: bookingId,
    );
    return model.toDomain();
  }

  @override
  Future<BookingEstimate> getEstimate({
    required String serviceId,
    required List<BookingStop> stops,
  }) async {
    final model = await _remoteDataSource.fetchEstimate(
      serviceId: serviceId,
      stops: stops,
    );
    return model.toDomain();
  }

  @override
  Future<BookingCreationResult> createBooking({
    required String serviceId,
    required String vehicleTypeId,
    required List<BookingStop> stops,
    String? paymentMethodId,
  }) async {
    final model = await _remoteDataSource.createBooking(
      serviceId: serviceId,
      vehicleTypeId: vehicleTypeId,
      stops: stops,
      paymentMethodId: paymentMethodId,
    );
    return model.toDomain();
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  }) {
    return _remoteDataSource.cancelBooking(
      bookingId: bookingId,
      reason: reason,
    );
  }

  @override
  Future<void> submitBookingReview({
    required String bookingId,
    required int ratingValue,
    required String comment,
  }) {
    return _remoteDataSource.submitBookingReview(
      bookingId: bookingId,
      ratingValue: ratingValue,
      comment: comment,
    );
  }

  @override
  Future<String> getBookingStatus({
    required String bookingId,
  }) {
    return _remoteDataSource.fetchBookingStatus(bookingId: bookingId);
  }

  @override
  Future<List<NearbyDriver>> getNearbyDrivers({
    required double lat,
    required double lng,
    required String serviceId,
    double radiusKm = 50,
  }) async {
    final models = await _remoteDataSource.fetchNearbyDrivers(
      lat: lat,
      lng: lng,
      serviceId: serviceId,
      radiusKm: radiusKm,
    );
    return models.map((model) => model.toDomain()).toList(growable: false);
  }
}
