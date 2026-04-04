import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/data/models/booking_model.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/payment_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/payment_state.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/pages/booking_card_widget.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos las reservas al entrar
    context.read<BookingBloc>().add(CustomerBookingsStreamStarted());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 1. Listener para las reservas (Booking)
        BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        // 2. Listener para los Pagos (Payment)
        BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentLoading) {
              // Opcional: Mostrar un diálogo de "Procesando pago..."
            }
            if (state is PaymentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("¡Pago procesado con éxito!"),
                  backgroundColor: Colors.blueAccent,
                  duration: Duration(seconds: 3),
                ),
              );
              // Aquí podrías cerrar algún modal o incluso refrescar manualmente
              // aunque el Stream de Booking debería hacerlo solo.
            }
            if (state is PaymentFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text("Mis Solicitudes")),
        body: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BookingsLoaded) {
              final activeBookings = state.bookings
                  .where((b) => b.status != BookingStatus.CANCELLED)
                  .toList();
              if (activeBookings.isEmpty) {
                return const Center(
                  child: Text("No has realizado reservas aún."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activeBookings.length,
                itemBuilder: (context, index) => BookingCard(
                  booking: activeBookings[index],
                  isProviderView: false,
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
