import 'package:services_marketplace_mobile/features/bookings/data/models/booking_model.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}
class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<BookingModel> bookings;
  BookingsLoaded(this.bookings);
}

class BookingSuccess extends BookingState {
  final String message;
  BookingSuccess(this.message);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}