import '../../domain/entities/booking_creation_result.dart';

class BookingCreationResponseModel {
  final String id;
  final String bookingId;
  final String status;

  const BookingCreationResponseModel({
    required this.id,
    required this.bookingId,
    required this.status,
  });

  factory BookingCreationResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingCreationResponseModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  BookingCreationResult toDomain() {
    return BookingCreationResult(
      id: id,
      bookingId: bookingId,
      status: status,
    );
  }
}