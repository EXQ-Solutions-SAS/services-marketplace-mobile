import 'package:dio/dio.dart';

class PaymentDataProvider {
  final Dio _dio;

  PaymentDataProvider(this._dio);

  /// POST /payments/process
  /// Envía la información para procesar un pago mock
  Future<Response> processPayment({
    required String bookingId,
    required double amount,
    required String paymentMethod,
  }) async {
    return await _dio.post(
      '/payments/process',
      data: {
        'bookingId': bookingId,
        'amount': amount,
        'paymentMethod': paymentMethod, // "CARD", "CASH", "TRANSFER"
      },
    );
  }

  /// GET /payments/status/:bookingId
  /// Verifica el estado actual de la transacción de una reserva
  Future<Response> getPaymentStatus(String bookingId) async {
    return await _dio.get('/payments/status/$bookingId');
  }
}