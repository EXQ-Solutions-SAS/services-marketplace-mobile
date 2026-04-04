import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository repository;

  PaymentBloc(this.repository) : super(PaymentInitial()) {
    on<ProcessPaymentRequested>((event, emit) async {
      emit(PaymentLoading());
      try {
        // Simulamos un retraso de red para que el usuario vea el spinner
        // y se sienta como una pasarela real
        await Future.delayed(const Duration(seconds: 2));

        final transaction = await repository.processPayment(
          bookingId: event.bookingId,
          amount: event.amount,
          paymentMethod: event.method,
        );

        emit(PaymentSuccess(transaction));
      } catch (e) {
        print("ERROR AL PAGAR: $e"); // Esto te dirá la verdad en la consola
        emit(PaymentFailure(e.toString()));
      }
    });

    on<VerifyPaymentRequested>((event, emit) async {
      // No emitimos Loading aquí para que la verificación sea silenciosa en la UI
      try {
        final transaction = await repository.getPaymentStatus(event.bookingId);
        emit(PaymentSuccess(transaction));
      } catch (e) {
        // Si falla la verificación, volvemos al estado inicial
        emit(PaymentInitial());
      }
    });
  }
}
