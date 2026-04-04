import 'package:services_marketplace_mobile/features/bookings/data/models/booking_model.dart';

abstract class BookingEvent {}

// Iniciar Streams
class CustomerBookingsStreamStarted extends BookingEvent {}
class ProviderBookingsStreamStarted extends BookingEvent {}

// Detener y Limpiar (Para el Logout que hablamos)
class StopBookingStream extends BookingEvent {}

// Actualización interna del Bloc cuando el Stream manda datos
class BookingsUpdated extends BookingEvent {
  final List<BookingModel> bookings;
  BookingsUpdated(this.bookings);
}

// Acciones (Se mantienen como Future porque son disparos únicos)
class CreateBookingRequested extends BookingEvent {
  final String serviceId;
  final DateTime date;
  final int hours;
  CreateBookingRequested(this.serviceId, this.date, this.hours);
}

class UpdateBookingStatusRequested extends BookingEvent {
  final String bookingId;
  final BookingStatus newStatus;
  UpdateBookingStatusRequested(this.bookingId, this.newStatus);
}