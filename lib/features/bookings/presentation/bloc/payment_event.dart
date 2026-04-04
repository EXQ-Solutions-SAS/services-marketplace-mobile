abstract class PaymentEvent {}

class ProcessPaymentRequested extends PaymentEvent {
  final String bookingId;
  final double amount;
  final String method; // "CARD", "CASH", "TRANSFER"

  ProcessPaymentRequested({
    required this.bookingId,
    required this.amount,
    required this.method,
  });
}

class VerifyPaymentRequested extends PaymentEvent {
  final String bookingId;
  VerifyPaymentRequested(this.bookingId);
}