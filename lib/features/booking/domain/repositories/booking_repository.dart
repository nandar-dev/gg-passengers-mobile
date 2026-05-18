import '../entities/active_booking.dart';
import '../entities/booking_estimate.dart';
import '../entities/booking_creation_result.dart';
import '../entities/nearby_driver.dart';
import '../entities/booking_stop.dart';

abstract class BookingRepository {
  Future<List<ActiveBooking>> getActiveBookings();

  Future<ActiveBooking> getActiveBookingById({
    required String bookingId,
  });

  Future<BookingEstimate> getEstimate({
    required String serviceId,
    required List<BookingStop> stops,
  });

  Future<BookingCreationResult> createBooking({
    required String serviceId,
    required String vehicleTypeId,
    required List<BookingStop> stops,
    String? paymentMethodId,
  });

  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  });

  Future<void> submitBookingReview({
    required String bookingId,
    required int ratingValue,
    required String comment,
  });

  Future<String> getBookingStatus({
    required String bookingId,
  });

  Future<List<NearbyDriver>> getNearbyDrivers({
    required double lat,
    required double lng,
    required String serviceId,
    double radiusKm = 50,
  });
}
