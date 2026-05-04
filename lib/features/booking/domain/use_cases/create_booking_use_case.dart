import 'package:injectable/injectable.dart';

import '../entities/booking_creation_result.dart';
import '../entities/booking_stop.dart';
import '../repositories/booking_repository.dart';

@lazySingleton
class CreateBookingUseCase {
  final BookingRepository _repository;

  CreateBookingUseCase(this._repository);

  Future<BookingCreationResult> call({
    required String serviceId,
    required String vehicleTypeId,
    required List<BookingStop> stops,
    String? paymentMethodId,
  }) {
    return _repository.createBooking(
      serviceId: serviceId,
      vehicleTypeId: vehicleTypeId,
      stops: stops,
      paymentMethodId: paymentMethodId,
    );
  }
}