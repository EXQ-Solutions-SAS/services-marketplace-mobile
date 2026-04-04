import 'booking_model.dart'; // Importa tu modelo de Booking

enum TransactionStatus {
  PENDING,
  COMPLETED,
  FAILED,
  REFUNDED,
}

class TransactionModel {
  final String id;
  final double amount;
  final TransactionStatus status;
  final String paymentMethod;
  final String? externalReference;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Ahora es un objeto completo, no solo el ID
  final BookingModel? booking; 

  TransactionModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.externalReference,
    required this.createdAt,
    required this.updatedAt,
    this.booking,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      // Mapeo del Enum según el esquema
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.PENDING,
      ),
      paymentMethod: json['paymentMethod'],
      externalReference: json['externalReference'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      // Mapeo del objeto anidado 'booking'
      booking: json['booking'] != null 
          ? BookingModel.fromJson(json['booking']) 
          : null,
    );
  }
}