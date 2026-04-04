import 'package:services_marketplace_mobile/features/bookings/data/models/review_model.dart';

abstract class ReviewEvent {}

// Evento para enviar una nueva
class SubmitReviewRequested extends ReviewEvent {
  final ReviewModel review;
  SubmitReviewRequested(this.review);
}

// Evento para traer las reseñas de un usuario (ej: el proveedor)
class FetchUserReviewsRequested extends ReviewEvent {
  final String userId;
  FetchUserReviewsRequested(this.userId);
}