import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/core/theme/app_theme.dart';
import 'package:services_marketplace_mobile/features/bookings/data/models/booking_model.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/payment_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/payment_state.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/review_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/review_state.dart';
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
                  backgroundColor: AppTheme.successBlue,
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
                  backgroundColor: AppTheme.successBlue,
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
        BlocListener<ReviewBloc, ReviewState>(
          listener: (context, state) {
            if (state is ReviewCreateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.successBlue,
                ),
              );

              // 🔥 ESTA ES LA CLAVE: Refrescamos la lista de reservas
              // para que desaparezca el botón de "Calificar"
              context.read<BookingBloc>().add(CustomerBookingsStreamStarted());
            }

            if (state is ReviewError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
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

            // En CustomerBookingsScreen
            if (state is BookingsLoaded) {
              print(  "DEBUG: Bookings cargadas: ${state.bookings.length} reservas"); // Debug
              // 1. Asegúrate de incluir COMPLETED aquí
              final activeBookings = state.bookings
                  .where((b) => b.status != BookingStatus.CANCELLED)
                  .toList();

              if (activeBookings.isEmpty) {
                return const Center(
                  child: Text("No has realizado reservas aún."),
                );
              }

              // 2. Agrega una Key al ListView para que Flutter sepa que debe reconstruirlo
              return ListView.builder(
                key: ValueKey(activeBookings.length),
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
