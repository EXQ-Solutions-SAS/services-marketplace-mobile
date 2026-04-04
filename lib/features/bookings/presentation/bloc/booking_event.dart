import 'package:services_marketplace_mobile/features/bookings/data/models/booking_model.dart';

abstract class BookingEvent {}

// Para el Cliente
class FetchCustomerBookingsRequested extends BookingEvent {}

// Para el Proveedor
class FetchProviderBookingsRequested extends BookingEvent {}

// Crear Reserva (Cliente)
class CreateBookingRequested extends BookingEvent {
  final String serviceId;
  final DateTime date;
  final int hours;
  CreateBookingRequested(this.serviceId, this.date, this.hours);
}

// Cambiar Estado (Ambos, pero principalmente Proveedor)
class UpdateBookingStatusRequested extends BookingEvent {
  final String bookingId;
  final BookingStatus newStatus;
  UpdateBookingStatusRequested(this.bookingId, this.newStatus);
}