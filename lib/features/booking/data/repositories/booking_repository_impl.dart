import 'package:injectable/injectable.dart';

import '../../domain/entities/booking_creation_result.dart';
import '../../domain/entities/booking_estimate.dart';
import '../../domain/entities/booking_stop.dart';
import '../../domain/repositories/booking_repository.dart';
import '../data_sources/booking_remote_data_source.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  BookingRepositoryImpl(this._remoteDataSource);

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
}
