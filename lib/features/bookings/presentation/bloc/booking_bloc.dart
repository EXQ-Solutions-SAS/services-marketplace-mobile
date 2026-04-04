import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/data/repositories/booking_repository.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/booking_event.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repository;
  final AuthBloc _authBloc;
  StreamSubscription? _authSubscription;
  StreamSubscription? _bookingSubscription;

  BookingBloc(this.repository, this._authBloc) : super(BookingInitial()) {
    
    // Escuchar Auth para cerrar todo al salir
    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState is Unauthenticated) add(StopBookingStream());
    });


    // STREAM CLIENTE
    on<CustomerBookingsStreamStarted>((event, emit) {
      _bookingSubscription?.cancel();
      emit(BookingLoading());
      _bookingSubscription = repository.getCustomerBookingsStream().listen(
        (bookings) => add(BookingsUpdated(bookings)),
        onError: (e) => add(BookingsUpdated([])), // O manejar error
      );
    });

    // STREAM PROVEEDOR
    on<ProviderBookingsStreamStarted>((event, emit) {
      _bookingSubscription?.cancel();
      emit(BookingLoading());
      _bookingSubscription = repository.getProviderBookingsStream().listen(
        (bookings) => add(BookingsUpdated(bookings)),
        onError: (e) => add(BookingsUpdated([])),
      );
    });

    // Actualizar UI con datos del Stream
    on<BookingsUpdated>((event, emit) {
      emit(BookingsLoaded(event.bookings));
    });

    // Detener todo
    on<StopBookingStream>((event, emit) {
      _bookingSubscription?.cancel();
      _bookingSubscription = null;
      emit(BookingInitial());
    });

    // ACCIONES (CREATE/UPDATE) - Se quedan como peticiones directas
    on<CreateBookingRequested>((event, emit) async {
      try {
        await repository.createBooking(event.serviceId, event.date, event.hours);
        emit(BookingSuccess("Reserva solicitada con éxito"));
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });

    on<UpdateBookingStatusRequested>((event, emit) async {
      try {
        await repository.updateStatus(event.bookingId, event.newStatus);
        emit(BookingSuccess("Estado actualizado"));
        // No hace falta re-fetch, el Stream lo hará solo!
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _bookingSubscription?.cancel();
    return super.close();
  }
}