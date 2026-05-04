import '../entities/booking_estimate.dart';
import '../entities/booking_creation_result.dart';
import '../entities/booking_stop.dart';

abstract class BookingRepository {
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
}
