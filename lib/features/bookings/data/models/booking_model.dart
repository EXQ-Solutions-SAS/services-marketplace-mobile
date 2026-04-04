import 'package:services_marketplace_mobile/features/bookings/data/models/review_model.dart';
import 'package:services_marketplace_mobile/features/bookings/data/models/transaction_model.dart';

enum BookingStatus { PENDING, ACCEPTED, PAID, COMPLETED, CANCELLED }

class BookingService {
  final String id;
  final String title;
  final double pricePerHour;

  BookingService({
    required this.id,
    required this.title,
    required this.pricePerHour,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) => BookingService(
    id: json['id'],
    title: json['title'],
    pricePerHour: (json['pricePerHour'] as num).toDouble(),
  );
}

class BookingUser {
  final String id;
  final String name;
  final String? email;
  final String? phone;

  BookingUser({required this.id, required this.name, this.email, this.phone});

  factory BookingUser.fromJson(Map<String, dynamic> json) => BookingUser(
    id: json['id'],
    name: json['name'] ?? 'Usuario',
    email: json['email'],
    phone: json['phone'],
  );
}

class BookingModel {
  final String id;
  final int hours;
  final double totalPrice;
  final DateTime scheduledAt;
  final BookingStatus status;

  final BookingService service;
  // Ambos opcionales para adaptarse a quién hace la consulta
  final String customerId;
  final BookingUser? customer;
  final BookingUser? provider;
  final TransactionModel? transaction;
  final List<ReviewModel> reviews; //

  BookingModel({
    required this.id,
    required this.hours,
    required this.totalPrice,
    required this.scheduledAt,
    required this.status,
    required this.service,
    required this.customerId,
    this.customer,
    this.provider,
    this.transaction,
    this.reviews = const [],
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      customerId: json['customerId'],
      hours: json['hours'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      scheduledAt: DateTime.parse(json['scheduledAt']),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.PENDING,
      ),
      service: BookingService.fromJson(json['service']),

      // Mapeo seguro: si el objeto no viene en el JSON, queda como null
      customer: json['customer'] != null
          ? BookingUser.fromJson(json['customer'])
          : null,

      provider: json['provider'] != null
          ? BookingUser.fromJson(json['provider']['user'] ?? json['provider'])
          : null,

      transaction: json['transaction'] != null
          ? TransactionModel.fromJson(json['transaction'])
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) {
              try {
                return ReviewModel.fromJson(r);
              } catch (e) {
                // Si falla una reseña, devolvemos un modelo mínimo para no romper la app
                print("Error mapeando una reseña: $e");
                return ReviewModel(reviewerId: r['reviewerId'] ?? '');
              }
            }).toList()
          : [],
    );
  }
}
