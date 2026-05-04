import 'package:injectable/injectable.dart';

import '../entities/booking_estimate.dart';
import '../entities/booking_stop.dart';
import '../repositories/booking_repository.dart';

@lazySingleton
class GetBookingEstimateUseCase {
  final BookingRepository _repository;

  GetBookingEstimateUseCase(this._repository);

  Future<BookingEstimate> call({
    required String serviceId,
    required List<BookingStop> stops,
  }) {
    return _repository.getEstimate(serviceId: serviceId, stops: stops);
  }
}
