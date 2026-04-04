import 'package:dio/dio.dart';
import 'package:services_marketplace_mobile/features/bookings/data/models/review_model.dart';

class ReviewDataProvider {
  final Dio _dio;

  ReviewDataProvider(this._dio);

  /// POST /reviews
  /// Envía la información para crear una reseña
  Future<Response> createReview(ReviewModel review) async {
    return await _dio.post('/reviews', data: {
        "bookingId": review.bookingId,
        "rating": review.rating,
        "comment": review.comment,
      },);
  }

  /// GET /reviews/user/:userId
  /// Obtiene las reseñas de un usuario
  Future<Response> getReviewsByUser(String userId) async {
    return await _dio.get('/reviews/user/$userId');
  }
}
