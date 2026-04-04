import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/data/models/booking_model.dart';
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
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Mis Solicitudes")),
        body: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BookingsLoaded) {
              final activeBookings = state.bookings.where((b) => b.status != BookingStatus.CANCELLED).toList();
              if (activeBookings.isEmpty) {
                return const Center(child: Text("No has realizado reservas aún."));
              }
              
              return  ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeBookings.length,
                  itemBuilder: (context, index) => BookingCard(booking: activeBookings[index], isProviderView: false),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}