import 'package:services_marketplace_mobile/features/bookings/data/models/review_model.dart';
import 'package:services_marketplace_mobile/features/bookings/data/providers/review_provider.dart';

class ReviewRepository {
  final ReviewDataProvider provider;

  ReviewRepository(this.provider);

  Future<void> submitReview(ReviewModel review) async {
    await provider.createReview(review);
  }

  Future<List<ReviewModel>> fetchReviewsByUser(String userId) async {
    final response = await provider.getReviewsByUser(userId);
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((json) => ReviewModel.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener las reseñas del usuario");
    }
  }
}