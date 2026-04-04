import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/data/models/booking_model.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import 'booking_card_widget.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos el dashboard específico del proveedor
    context.read<BookingBloc>().add(ProviderBookingsStreamStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
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
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Panel de Proveedor")),
        body: BlocBuilder<BookingBloc, BookingState>(
          // Solo redibujamos la lista si cargamos datos nuevos
          buildWhen: (previous, current) =>
              current is BookingsLoaded || current is BookingLoading,
          builder: (context, state) {
            if (state is BookingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BookingsLoaded) {
              final bookings = state.bookings
                  .where((b) => b.status != BookingStatus.CANCELLED)
                  .toList();

              if (bookings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_late_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text("No tienes solicitudes de servicio todavía."),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return BookingCard(
                    booking: bookings[index],
                    isProviderView:
                        true, // <--- Habilitamos los botones de Aceptar/Completar
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
