import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:services_marketplace_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/data/models/booking_model.dart';
import 'package:services_marketplace_mobile/features/bookings/data/models/review_model.dart';
import 'package:services_marketplace_mobile/features/bookings/data/models/transaction_model.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/booking_event.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/payment_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/payment_event.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/review_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/review_event.dart';

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
    final authState = context
        .read<AuthBloc>()
        .state; // Suponiendo que tienes un AuthBloc
    final String currentUserId =
        authState.user?.id ??
        ''; // ID del usuario actual para lógica de reseñas
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
            _buildFooter(context, currentUserId),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, String currentUserId) {
    final now = DateTime.now();
    final isPastTime = now.isAfter(booking.scheduledAt);
    final bool isPaid =
        booking.status == BookingStatus.PAID ||
        booking.transaction?.status == TransactionStatus.COMPLETED;
    final bool hasIReviewed = booking.reviews.any(
      (r) => r.reviewerId == currentUserId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            // BOTÓN CANCELAR: Se muestra si está pendiente o aceptado pero no pagado
            if (booking.status == BookingStatus.PENDING ||
                booking.status == BookingStatus.ACCEPTED)
              OutlinedButton(
                onPressed: () => _handleCancelation(context, isPastTime),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text("Cancelar"),
              ),

            // BOTÓN ACEPTAR: Solo para el Proveedor cuando está PENDING
            if (isProviderView && booking.status == BookingStatus.PENDING)
              ElevatedButton(
                onPressed: () => _updateStatus(context, BookingStatus.ACCEPTED),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Aceptar"),
              ),

            // BOTÓN PAGAR: Solo para el Cliente, si está ACCEPTED y NO ha pagado
            if (!isProviderView &&
                booking.status == BookingStatus.ACCEPTED &&
                isPastTime &&
                !isPaid)
              ElevatedButton.icon(
                onPressed: () => _showPaymentModal(context, booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.account_balance_wallet, size: 18),
                label: const Text("Pagar Servicio"),
              ),

            // INDICADOR DE PAGO: Un chip visual para confirmar que el dinero ya está en el sistema
            if (isPaid && booking.status != BookingStatus.COMPLETED)
              const Chip(
                backgroundColor: Color(0xFF1E2329),
                avatar: Icon(Icons.check_circle, color: Colors.green, size: 20),
                label: Text(
                  "Pago Confirmado",
                  style: TextStyle(color: Colors.white),
                ),
              ),

            // BOTÓN COMPLETAR: Solo para el Proveedor y SOLO si el estado es PAID
            if (isProviderView && booking.status == BookingStatus.PAID)
              ElevatedButton(
                onPressed: () =>
                    _updateStatus(context, BookingStatus.COMPLETED),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Finalizar Servicio"),
              ),

            // AVISO PARA EL PROVEEDOR: Si ya aceptó pero el cliente no ha pagado
            if (isProviderView &&
                booking.status == BookingStatus.ACCEPTED &&
                isPastTime &&
                !isPaid)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Esperando pago del cliente...",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            if (booking.status == BookingStatus.COMPLETED && !hasIReviewed)
              ElevatedButton.icon(
                onPressed: () => _showReviewModal(context, booking, currentUserId),
                icon: const Icon(Icons.star_border),
                label: Text(
                  isProviderView ? "Calificar Cliente" : "Calificar Servicio",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _handleCancelation(BuildContext context, bool isPastTime) {
    if (!isPastTime) {
      // Caso 1: Cancelación normal (antes de la hora)
      _updateStatus(context, BookingStatus.CANCELLED);
      return;
    }

    // Caso 2: Ya pasó la hora o está en curso, advertir sobre la multa
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("¡Atención!"),
          ],
        ),
        content: Text(
          isProviderView
              ? "Como el servicio ya debería haber iniciado, cancelar ahora podría afectar tu calificación y generar cargos administrativos."
              : "El servicio ya está en curso. Si cancelas ahora, no se realizará el reembolso del depósito por políticas de cancelación tardía.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Regresar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Cierra el modal
              _updateStatus(
                context,
                BookingStatus.CANCELLED,
              ); // Ejecuta la cancelación
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Confirmar y Cancelar"),
          ),
        ],
      ),
    );
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
      case BookingStatus.PAID:
        statusColor = Colors.pinkAccent;
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
          Icon(icon, size: 16, color: Colors.grey[200]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  } // Aquí va el título y el Badge de estado

  void _showPaymentModal(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: const Color(0xFF1A1F24), // Fondo oscuro para que combine
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Finalizar Pago",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Total a transferir: \$${booking.totalPrice.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Opciones de Pago
              _paymentOption(
                context,
                icon: Icons.credit_card,
                title: "Tarjeta de Crédito/Débito",
                method: "CARD",
                booking: booking,
              ),
              _paymentOption(
                context,
                icon: Icons.account_balance,
                title: "Transferencia Bancaria",
                method: "TRANSFER",
                booking: booking,
              ),
              _paymentOption(
                context,
                icon: Icons.payments,
                title: "Efectivo",
                method: "CASH",
                booking: booking,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _paymentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String method,
    required BookingModel booking,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // Cierra el modal
        // Disparamos el proceso de pago
        context.read<PaymentBloc>().add(
          ProcessPaymentRequested(
            bookingId: booking.id,
            amount: booking.totalPrice,
            method: method,
          ),
        );
      },
    );
  }

  void _showReviewModal(
    BuildContext context,
    BookingModel booking,
    String currentUserId,
  ) {
    int selectedRating = 5;
    final TextEditingController commentController = TextEditingController();

    // Lógica de IDs (Esto se queda igual porque el backend lo necesita)
    final bool isCustomer = booking.customerId == currentUserId;
    final String reviewerId = currentUserId;
    final String revieweeId = isCustomer
        ? (booking.provider?.id ?? '') // Id del proveedor
        : booking.customerId; // Id del cliente

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Calificar Experiencia", // Título neutro
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCustomer
                    ? "¿Qué tal te pareció el servicio recibido?"
                    : "¿Cómo calificarías la interacción con el cliente?",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Selector de Estrellas
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () =>
                            setModalState(() => selectedRating = index + 1),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                maxLength: 200, // Limitar comentarios ayuda al diseño
                decoration: InputDecoration(
                  hintText: "Escribe un comentario opcional...",
                  hintStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (revieweeId.isEmpty) return; // Seguridad extra

                final review = ReviewModel(
                  rating: selectedRating,
                  comment: commentController.text.trim(),
                  bookingId: booking.id,
                  reviewerId: reviewerId,
                  revieweeId: revieweeId,
                );

                context.read<ReviewBloc>().add(SubmitReviewRequested(review));
                Navigator.pop(context);
              },
              child: const Text("Enviar Reseña"),
            ),
          ],
        );
      },
    );
  }
}
