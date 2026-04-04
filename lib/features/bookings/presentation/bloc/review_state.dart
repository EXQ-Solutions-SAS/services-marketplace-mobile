import 'package:services_marketplace_mobile/features/bookings/data/models/review_model.dart';

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

// Estado para cuando se CREA una reseña
class ReviewCreateSuccess extends ReviewState {
  final String message;
  ReviewCreateSuccess(this.message);
}

// Estado para cuando se CARGAN las reseñas de un usuario
class ReviewsLoaded extends ReviewState {
  final List<ReviewModel> reviews;
  ReviewsLoaded(this.reviews);
}

class ReviewError extends ReviewState {
  final String message;
  ReviewError(this.message);
}