import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/bookings/data/repositories/review_repository.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/review_event.dart';
import 'package:services_marketplace_mobile/features/bookings/presentation/bloc/review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;

  ReviewBloc(this.repository) : super(ReviewInitial()) {
    
    // Lógica para CREAR
    on<SubmitReviewRequested>((event, emit) async {
      emit(ReviewLoading());
      try {
         await repository.submitReview(event.review);
        emit(ReviewCreateSuccess('Reseña enviada exitosamente.'));
      } catch (e) {
        emit(ReviewError("No se pudo enviar la reseña."));
      }
    });

    // Lógica para TRAER LISTA
    on<FetchUserReviewsRequested>((event, emit) async {
      emit(ReviewLoading());
      try {
        final reviews = await repository.fetchReviewsByUser(event.userId);
        emit(ReviewsLoaded(reviews));
      } catch (e) {
        emit(ReviewError("No se pudieron cargar las reseñas del usuario."));
      }
    });
  }
}