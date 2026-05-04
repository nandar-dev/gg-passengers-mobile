import 'package:equatable/equatable.dart';

class BookingCreationResult extends Equatable {
  final String id;
  final String bookingId;
  final String status;

  const BookingCreationResult({
    required this.id,
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object?> get props => [id, bookingId, status];
}