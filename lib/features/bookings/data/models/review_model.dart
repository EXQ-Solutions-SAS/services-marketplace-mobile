class ReviewModel {
  final String? id;
  final int rating;
  final String comment;
  final String reviewerId;
  final String? bookingId;
  final String? revieweeId;

  ReviewModel({
    this.id,
    this.rating = 0, // Valor por defecto
    this.comment = '', // Valor por defecto
    required this.reviewerId,
    this.bookingId,
    this.revieweeId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String?,
      // Usamos as num? y ?? para que si no existe el campo no explote
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      reviewerId: json['reviewerId'] as String? ?? '', // Este es el que sí llega
      bookingId: json['bookingId'] as String?,
      revieweeId: json['revieweeId'] as String? ?? '',
    );
  }
}