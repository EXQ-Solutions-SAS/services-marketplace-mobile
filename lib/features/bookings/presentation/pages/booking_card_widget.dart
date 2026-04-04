import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:services_marketplace_mobile/features/bookings/data/models/booking_model.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/booking_event.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isProviderView; // <-- La clave para diferenciar

  const BookingCard({
    super.key,
    required this.booking,
    this.isProviderView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              DateFormat('dd/MM/yyyy - hh:mm a').format(booking.scheduledAt),
            ),
            _buildInfoRow(
              Icons.person,
              isProviderView
                  ? "Cliente: ${booking.customer?.name ?? 'N/A'}"
                  : "Proveedor: ${booking.provider?.name ?? 'N/A'}",
            ),
            if (booking.customer?.phone != null && isProviderView)
              _buildInfoRow(Icons.phone, "Tel: ${booking.customer!.phone}"),
            const Divider(),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los botones al ancho total
    children: [
      // 1. Fila del Precio (Arriba)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total a pagar",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            "\$${booking.totalPrice.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12), // Espacio entre precio y botones

      // 2. Bloque de Botones (Abajo)
      // Usamos un Wrap para que si hay muchos botones, bajen solitos sin romperse
      Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end, // Los alinea a la derecha
        children: [
          // Botón Cancelar
          if (booking.status == BookingStatus.PENDING)
            OutlinedButton(
              onPressed: () => _updateStatus(context, BookingStatus.CANCELLED),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text("Cancelar"),
            ),

          // Botón Aceptar (Solo Provider)
          if (isProviderView && booking.status == BookingStatus.PENDING)
            ElevatedButton(
              onPressed: () => _updateStatus(context, BookingStatus.ACCEPTED),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Como en tu imagen
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 45), // Le damos un buen tamaño
              ),
              child: const Text("Aceptar"),
            ),

          // Botón Completar (Solo Provider)
          if (isProviderView && booking.status == BookingStatus.ACCEPTED)
            ElevatedButton(
              onPressed: _canComplete() 
                  ? () => _updateStatus(context, BookingStatus.COMPLETED)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 45),
              ),
              child: const Text("Completar"),
            ),
        ],
      ),
    ],
  );
}
  // Validación de tiempo que mencionaste
  bool _canComplete() {
    // Solo permite completar si ya pasó la hora de la cita
    return DateTime.now().isAfter(booking.scheduledAt);
  }

  void _updateStatus(BuildContext context, BookingStatus status) {
    context.read<BookingBloc>().add(
      UpdateBookingStatusRequested(booking.id, status),
    );
  }

  // Widgets auxiliares para no repetir código de diseño...
  Widget _buildHeader() {
    Color statusColor;
    String statusText = booking.status.name;

    switch (booking.status) {
      case BookingStatus.PENDING:
        statusColor = Colors.orange;
        break;
      case BookingStatus.ACCEPTED:
        statusColor = Colors.blue;
        break;
      case BookingStatus.COMPLETED:
        statusColor = Colors.green;
        break;
      case BookingStatus.CANCELLED:
        statusColor = Colors.red;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            booking.service.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.5)),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  } // Aquí va el título y el Badge de estado
}
