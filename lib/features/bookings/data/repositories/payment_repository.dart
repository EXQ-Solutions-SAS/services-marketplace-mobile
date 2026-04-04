import '../models/transaction_model.dart';
import '../providers/payment_provider.dart';

class PaymentRepository {
  final PaymentDataProvider provider;

  PaymentRepository(this.provider);

  // Procesa el pago mock
  Future<TransactionModel> processPayment({
    required String bookingId,
    required double amount,
    required String paymentMethod,
  }) async {
    //
    final response = await provider.processPayment(
      bookingId: bookingId,
      amount: amount,
      paymentMethod: paymentMethod,
    );
    final transactionData =
        response.data['transaction'] as Map<String, dynamic>;

    return TransactionModel.fromJson(transactionData);
  }

  // Verifica el estado actual de un pago
  Future<TransactionModel> getPaymentStatus(String bookingId) async {
    final response = await provider.getPaymentStatus(bookingId);

    // Como tu JSON de verify payment trae el objeto 'booking' anidado,
    // nuestro model ya lo maneja en el fromJson.
    final transactionData =
        response.data['transaction'] as Map<String, dynamic>;

    return TransactionModel.fromJson(transactionData);
  }
}
