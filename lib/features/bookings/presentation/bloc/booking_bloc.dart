import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/data/repositories/booking_repository.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/booking_event.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repository;

  BookingBloc(this.repository) : super(BookingInitial()) {
    
    // Cargar Reservas del Cliente
    on<FetchCustomerBookingsRequested>((event, emit) async {
      emit(BookingLoading());
      try {
        final bookings = await repository.getCustomerBookings();
        emit(BookingsLoaded(bookings));
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });

    // Cargar Dashboard del Proveedor
    on<FetchProviderBookingsRequested>((event, emit) async {
      emit(BookingLoading());
      try {
        final bookings = await repository.getProviderBookings();
        emit(BookingsLoaded(bookings));
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });

    // Crear Reserva
    on<CreateBookingRequested>((event, emit) async {
      emit(BookingLoading());
      try {
        await repository.createBooking(event.serviceId, event.date, event.hours);
        emit(BookingSuccess("Reserva solicitada con éxito"));
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });

    // Actualizar Estado (Aceptar/Cancelar/Completar)
    on<UpdateBookingStatusRequested>((event, emit) async {
      try {
        await repository.updateStatus(event.bookingId, event.newStatus);
        emit(BookingSuccess("Estado actualizado a ${event.newStatus.name}"));
        // Opcional: Podrías disparar el Fetch de nuevo aquí
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });
  }
}