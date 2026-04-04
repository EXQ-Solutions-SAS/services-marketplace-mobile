import '../../data/models/transaction_model.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final TransactionModel transaction;
  PaymentSuccess(this.transaction);
}

class PaymentFailure extends PaymentState {
  final String error;
  PaymentFailure(this.error);
}